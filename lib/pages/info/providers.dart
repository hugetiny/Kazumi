import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/modules/characters/character_item.dart';
import 'package:kazumi/modules/staff/staff_item.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';

// ✅ 导出 Info 页面 UI 状态管理
export 'package:kazumi/pages/info/info_ui_state.dart';

/// 番剧详情页 Provider
///
/// 管理番剧详细信息、评论、角色、制作人员和元数据。
/// 支持从 Bangumi、TMDB 等源获取和合并元数据。
///
/// 示例:
/// ```dart
/// final controller = ref.read(bangumiInfoProvider.notifier);
/// await controller.queryBangumiInfoByID(12345);
/// ```
final bangumiInfoProvider =
    NotifierProvider.autoDispose<InfoController, InfoState>(InfoController.new);

// ✅ Bangumi Comments Provider (支持分页)
class BangumiCommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<CommentItem>, (int, int)> {
  @override
  Future<List<CommentItem>> build((int, int) arg) async {
    final (bangumiId, offset) = arg;

    try {
      final result = await BangumiHTTP.getBangumiCommentsByID(
        bangumiId,
        offset: offset,
      );
      KazumiLogger().log(Level.info, '已加载评论列表长度 ${result.commentList.length}');
      return result.commentList;
    } catch (error, stackTrace) {
      KazumiLogger().log(
        Level.error,
        '加载评论失败: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh comments
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final bangumiCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiCommentsNotifier, List<CommentItem>, (int, int)>(
  BangumiCommentsNotifier.new,
);

// ✅ Bangumi Characters Provider
class BangumiCharactersNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<CharacterItem>, int> {
  @override
  Future<List<CharacterItem>> build(int bangumiId) async {
    try {
      final result = await BangumiHTTP.getCharatersByBangumiID(bangumiId);
      final characters = result.charactersList;
      const relationValue = {'主角': 1, '配角': 2, '客串': 3};

      try {
        characters.sort((a, b) {
          final valueA = relationValue[a.relation] ?? 4;
          final valueB = relationValue[b.relation] ?? 4;
          return valueA.compareTo(valueB);
        });
      } catch (e) {
        KazumiDialog.showToast(
          message: t.library.info.toast.characterSortFailed.replaceFirst(
            '{details}',
            e.toString(),
          ),
        );
      }

      KazumiLogger().log(Level.info, '已加载角色列表长度 ${characters.length}');
      return characters;
    } catch (error, stackTrace) {
      KazumiLogger().log(
        Level.error,
        '加载角色列表失败: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh characters
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final bangumiCharactersProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiCharactersNotifier, List<CharacterItem>, int>(
  BangumiCharactersNotifier.new,
);

// ✅ Bangumi Staff Provider
class BangumiStaffsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<StaffFullItem>, int> {
  @override
  Future<List<StaffFullItem>> build(int bangumiId) async {
    try {
      final result = await BangumiHTTP.getBangumiStaffByID(bangumiId);
      final staff = result.data;
      KazumiLogger().log(Level.info, '已加载制作人员列表长度 ${staff.length}');
      return staff;
    } catch (error, stackTrace) {
      KazumiLogger().log(
        Level.error,
        '加载制作人员列表失败: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh staff
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final bangumiStaffsProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiStaffsNotifier, List<StaffFullItem>, int>(
  BangumiStaffsNotifier.new,
);
