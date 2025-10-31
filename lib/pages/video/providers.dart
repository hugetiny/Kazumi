import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/video/video_state.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

/// 视频播放页面 Provider
///
/// 管理番剧剧集列表、播放线路和 WebView 抓取。
/// 协调播放器控制和剧集切换逻辑。
///
/// 示例:
/// ```dart
/// final controller = ref.read(videoProvider.notifier);
/// await controller.changeEpisode(episodeIndex, roadIndex);
/// ```
final videoProvider =
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

// ✅ Episode Comments Sheet UI State
// Stores manually selected episode number (null means use current episode)
final selectedEpisodeProvider = StateProvider.autoDispose<int?>((ref) => null);

// ✅ Video Page UI State Providers
final showDebugLogProvider = StateProvider.autoDispose<bool>((ref) => false);
final webviewLogLinesProvider = StateProvider.autoDispose<List<String>>((ref) => []);
final currentRoadProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Provider for current episode number (replaces EpisodeInfo InheritedWidget)
/// This is computed from videoState and used by EpisodeCommentsSheet
final currentEpisodeNumberProvider = Provider.autoDispose<int>((ref) {
  final videoState = ref.watch(videoProvider);
  return videoState.currentEpisode;
});
