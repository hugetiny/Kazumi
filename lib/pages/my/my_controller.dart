import 'package:hive/hive.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/utils/auto_updater.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

class MyState {
  final List<String> shieldList;

  const MyState({this.shieldList = const []});

  MyState copyWith({List<String>? shieldList}) {
    return MyState(
      shieldList: shieldList ?? this.shieldList,
    );
  }
}

class MyController extends SafeStateNotifier<MyState> {
  MyController() : super(const MyState());

  final Box setting = GStorage.setting;

  /// Initializes shield keywords from persistent storage.
  void loadShieldList() {
    final values = GStorage.shieldList.values.cast<String>().toList();
    state = state.copyWith(shieldList: List.unmodifiable(values));
  }

  bool isDanmakuBlocked(String? danmaku) {
    if (danmaku == null || danmaku.isEmpty) return false;
    for (final item in state.shieldList) {
      if (item.isEmpty) continue;
      if (item.startsWith('/') && item.endsWith('/')) {
        if (item.length <= 2) continue;
        final pattern = item.substring(1, item.length - 1);
        try {
          if (RegExp(pattern).hasMatch(danmaku)) return true;
        } catch (_) {
          KazumiLogger().log(Level.error, '无效的弹幕屏蔽正则表达式: $pattern');
        }
      } else if (danmaku.contains(item)) {
        return true;
      }
    }
    return false;
  }

  void addShieldList(String item) {
    final trimmed = item.trim();
    if (trimmed.isEmpty) {
      KazumiDialog.showToast(message: '请输入关键词');
      return;
    }
    if (trimmed.length > 64) {
      KazumiDialog.showToast(message: '关键词过长');
      return;
    }
    if (state.shieldList.contains(trimmed)) {
      KazumiDialog.showToast(message: '已存在该关键词');
      return;
    }

    final updated = List<String>.from(state.shieldList)..add(trimmed);
    state = state.copyWith(shieldList: List.unmodifiable(updated));
    GStorage.shieldList.put(trimmed, trimmed);
    GStorage.shieldList.flush();
  }

  void removeShieldList(String item) {
    final updated = List<String>.from(state.shieldList)..remove(item);
    state = state.copyWith(shieldList: List.unmodifiable(updated));
    GStorage.shieldList.delete(item);
    GStorage.shieldList.flush();
  }

  Future<bool> checkUpdate({String type = 'manual'}) async {
    try {
      final autoUpdater = AutoUpdater();
      if (type == 'manual') {
        await autoUpdater.manualCheckForUpdates();
      } else {
        await autoUpdater.autoCheckForUpdates();
      }
      return true;
    } catch (err) {
      KazumiLogger().log(Level.error, '检查更新失败 ${err.toString()}');
      if (type == 'manual') {
        KazumiDialog.showToast(message: '检查更新失败，请稍后重试');
      }
      return false;
    }
  }
}

final myControllerProvider =
    StateNotifierProvider<MyController, MyState>((ref) => MyController());
