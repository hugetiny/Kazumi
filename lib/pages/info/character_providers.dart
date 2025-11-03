import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/modules/character/character_full_item.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

// ✅ Character Detail Provider
class CharacterDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<CharacterFullItem, int> {
  @override
  Future<CharacterFullItem> build(int characterId) async {
    try {
      final character =
          await BangumiHTTP.getCharacterByCharacterID(characterId);
      KazumiLogger().log(Level.info, '已加载角色详情: ${character.name}');
      return character;
    } catch (error, stackTrace) {
      KazumiLogger().log(
        Level.error,
        '加载角色详情失败: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh character detail
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final characterDetailProvider = AsyncNotifierProvider.autoDispose
    .family<CharacterDetailNotifier, CharacterFullItem, int>(
  CharacterDetailNotifier.new,
);

// ✅ Character Comments Provider
class CharacterCommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<CharacterCommentItem>, int> {
  @override
  Future<List<CharacterCommentItem>> build(int characterId) async {
    try {
      final result =
          await BangumiHTTP.getCharacterCommentsByCharacterID(characterId);
      KazumiLogger()
          .log(Level.info, '已加载角色评论列表长度 ${result.commentList.length}');
      return result.commentList;
    } catch (error, stackTrace) {
      KazumiLogger().log(
        Level.error,
        '加载角色评论失败: $error',
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

final characterCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<CharacterCommentsNotifier, List<CharacterCommentItem>, int>(
  CharacterCommentsNotifier.new,
);
