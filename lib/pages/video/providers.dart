import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/video/video_state.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

final videoControllerProvider =
    NotifierProvider<VideoPageController, VideoPageState>(
  VideoPageController.new,
);

/// AsyncNotifier for episode comments
/// Provides cleaner async state management for loading comments
class EpisodeCommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<EpisodeCommentItem>, (int, int)> {
  @override
  Future<List<EpisodeCommentItem>> build((int, int) arg) async {
    final (bangumiId, episode) = arg;

    try {
      // Load episode info
      final episodeInfo = await BangumiHTTP.getBangumiEpisodeByID(bangumiId, episode);

      // Load comments for this episode
      final result = await BangumiHTTP.getBangumiCommentsByEpisodeID(episodeInfo.id);

      KazumiLogger().log(
        Level.info,
        '已加载评论列表长度 ${result.commentList.length}',
      );

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

final episodeCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<EpisodeCommentsNotifier, List<EpisodeCommentItem>, (int, int)>(
  EpisodeCommentsNotifier.new,
);
