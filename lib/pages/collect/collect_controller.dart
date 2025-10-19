import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/collect/collect_module.dart';
import 'package:kazumi/modules/collect/collect_change_module.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/webdav.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

class CollectState {
  final List<CollectedBangumi> collectibles;
  final bool syncing;

  const CollectState({
    this.collectibles = const [],
    this.syncing = false,
  });

  CollectState copyWith({
    List<CollectedBangumi>? collectibles,
    bool? syncing,
  }) => CollectState(
        collectibles: collectibles ?? this.collectibles,
        syncing: syncing ?? this.syncing,
      );
}

class CollectController extends SafeStateNotifier<CollectState> {
  CollectController() : super(const CollectState());

  Box get setting => GStorage.setting;
  List<BangumiItem> get favorites => GStorage.favorites.values.toList();

  void loadCollectibles() {
    state = state.copyWith(
      collectibles: GStorage.collectibles.values.toList(),
    );
  }

  int getCollectType(BangumiItem bangumiItem) {
    final collectedBangumi = GStorage.collectibles.get(bangumiItem.id);
    return collectedBangumi?.type ?? 0;
  }

  Future<void> addCollect(BangumiItem bangumiItem, {int type = 1}) async {
    if (type == 0) {
      await deleteCollect(bangumiItem);
      return;
    }
    final collectedBangumi = CollectedBangumi(bangumiItem, DateTime.now(), type);
    await GStorage.collectibles.put(bangumiItem.id, collectedBangumi);
    await GStorage.collectibles.flush();
    final collectChangeId = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final collectChange = CollectedBangumiChange(
      collectChangeId,
      bangumiItem.id,
      1,
      type,
      (DateTime.now().millisecondsSinceEpoch ~/ 1000),
    );
    await GStorage.collectChanges.put(collectChangeId, collectChange);
    await GStorage.collectChanges.flush();
    loadCollectibles();
  }

  Future<void> deleteCollect(BangumiItem bangumiItem) async {
    await GStorage.collectibles.delete(bangumiItem.id);
    await GStorage.collectibles.flush();
    final collectChangeId = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final collectChange = CollectedBangumiChange(
      collectChangeId,
      bangumiItem.id,
      3,
      5,
      (DateTime.now().millisecondsSinceEpoch ~/ 1000),
    );
    await GStorage.collectChanges.put(collectChangeId, collectChange);
    await GStorage.collectChanges.flush();
    loadCollectibles();
  }

  Future<void> updateLocalCollect(BangumiItem bangumiItem) async {
    final collectedBangumi = GStorage.collectibles.get(bangumiItem.id);
    if (collectedBangumi == null) return;
    collectedBangumi.bangumiItem = bangumiItem;
    await GStorage.collectibles.put(bangumiItem.id, collectedBangumi);
    await GStorage.collectibles.flush();
    loadCollectibles();
  }

  Future<void> syncCollectibles() async {
    if (!WebDav().initialized) {
      KazumiDialog.showToast(message: '未开启WebDav同步或配置无效');
      return;
    }
    state = state.copyWith(syncing: true);
    var ok = true;
    try {
      await WebDav().ping();
    } catch (e) {
      KazumiLogger().log(Level.error, 'WebDav连接失败: $e');
      KazumiDialog.showToast(message: 'WebDav连接失败: $e');
      ok = false;
    }
    if (ok) {
      try {
        await WebDav().syncCollectibles();
      } catch (e) {
        KazumiDialog.showToast(message: 'WebDav同步失败 $e');
      }
      loadCollectibles();
    }
    state = state.copyWith(syncing: false);
  }

  Future<void> migrateCollect() async {
    if (favorites.isEmpty) return;
    int count = 0;
    for (final item in favorites) {
      await addCollect(item, type: 1);
      count++;
    }
    await GStorage.favorites.clear();
    await GStorage.favorites.flush();
    KazumiLogger().log(Level.debug, '检测到$count条未分类追番记录, 已迁移');
  }
}

