import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/bangumi/episode_item.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/modules/roads/road_module.dart';
import 'package:kazumi/plugins/plugins.dart';

class VideoPageState {
  const VideoPageState({
    this.bangumiItem,
    required this.episodeInfo,
    required this.episodeComments,
    required this.loading,
    required this.currentEpisode,
    required this.currentRoad,
    required this.isFullscreen,
    required this.isPip,
    required this.showTabBody,
    required this.historyOffset,
    required this.title,
    required this.src,
    required this.roadList,
    this.currentPlugin,
  });

  factory VideoPageState.initial() => VideoPageState(
        bangumiItem: null,
        episodeInfo: EpisodeInfo.fromTemplate(),
        episodeComments: const [],
        loading: true,
        currentEpisode: 1,
        currentRoad: 0,
        isFullscreen: false,
        isPip: false,
        showTabBody: true,
        historyOffset: 0,
        title: '',
        src: '',
        roadList: const [],
        currentPlugin: null,
      );

  final BangumiItem? bangumiItem;
  final EpisodeInfo episodeInfo;
  final List<EpisodeCommentItem> episodeComments;
  final bool loading;
  final int currentEpisode;
  final int currentRoad;
  final bool isFullscreen;
  final bool isPip;
  final bool showTabBody;
  final int historyOffset;
  final String title;
  final String src;
  final List<Road> roadList;
  final Plugin? currentPlugin;

  VideoPageState copyWith({
    BangumiItem? bangumiItem,
    EpisodeInfo? episodeInfo,
    List<EpisodeCommentItem>? episodeComments,
    bool? loading,
    int? currentEpisode,
    int? currentRoad,
    bool? isFullscreen,
    bool? isPip,
    bool? showTabBody,
    int? historyOffset,
    String? title,
    String? src,
    List<Road>? roadList,
    Plugin? currentPlugin,
    bool resetEpisodeComments = false,
  }) {
    return VideoPageState(
      bangumiItem: bangumiItem ?? this.bangumiItem,
      episodeInfo: episodeInfo ?? this.episodeInfo,
      episodeComments: resetEpisodeComments
          ? const []
          : (episodeComments ?? this.episodeComments),
      loading: loading ?? this.loading,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      currentRoad: currentRoad ?? this.currentRoad,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isPip: isPip ?? this.isPip,
      showTabBody: showTabBody ?? this.showTabBody,
      historyOffset: historyOffset ?? this.historyOffset,
      title: title ?? this.title,
      src: src ?? this.src,
      roadList: roadList ?? this.roadList,
      currentPlugin: currentPlugin ?? this.currentPlugin,
    );
  }

  @override
  int get hashCode => Object.hashAll([
        bangumiItem,
        episodeInfo,
        Object.hashAll(episodeComments),
        loading,
        currentEpisode,
        currentRoad,
        isFullscreen,
        isPip,
        showTabBody,
        historyOffset,
        title,
        src,
        Object.hashAll(roadList),
        currentPlugin,
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VideoPageState) return false;
    return other.bangumiItem == bangumiItem &&
        other.episodeInfo == episodeInfo &&
        _listEquals(other.episodeComments, episodeComments) &&
        other.loading == loading &&
        other.currentEpisode == currentEpisode &&
        other.currentRoad == currentRoad &&
        other.isFullscreen == isFullscreen &&
        other.isPip == isPip &&
        other.showTabBody == showTabBody &&
        other.historyOffset == historyOffset &&
        other.title == title &&
        other.src == src &&
        _listEquals(other.roadList, roadList) &&
        other.currentPlugin == currentPlugin;
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
