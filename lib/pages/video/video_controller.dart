import 'dart:async';

import 'package:dio/dio.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/bangumi/episode_item.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/modules/roads/road_module.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

import 'video_state.dart';

class VideoPageController extends SafeStateNotifier<VideoPageState> {
  VideoPageController({
    required this.pluginsController,
    required this.webviewController,
  }) : super(VideoPageState.initial());

  final PluginsController pluginsController;
  final WebviewItemController<dynamic> webviewController;

  CancelToken? _queryRoadsCancelToken;

  BangumiItem get bangumiItem {
    final item = state.bangumiItem;
    if (item == null) {
      throw StateError('bangumiItem is not set');
    }
    return item;
  }

  set bangumiItem(BangumiItem value) {
    state = state.copyWith(bangumiItem: value);
  }

  EpisodeInfo get episodeInfo => state.episodeInfo;
  set episodeInfo(EpisodeInfo value) {
    state = state.copyWith(episodeInfo: value);
  }

  List<EpisodeCommentItem> get episodeCommentsList => state.episodeComments;

  void resetEpisodeInfo() {
    state = state.copyWith(episodeInfo: EpisodeInfo.fromTemplate());
  }

  void clearEpisodeComments() {
    state = state.copyWith(resetEpisodeComments: true);
  }

  void addEpisodeComments(Iterable<EpisodeCommentItem> comments) {
    final updated = [...state.episodeComments, ...comments];
    state = state.copyWith(episodeComments: updated);
  }

  bool get loading => state.loading;
  set loading(bool value) {
    if (state.loading == value) return;
    state = state.copyWith(loading: value);
  }

  int get currentEpisode => state.currentEpisode;
  set currentEpisode(int value) {
    if (state.currentEpisode == value) return;
    state = state.copyWith(currentEpisode: value);
  }

  int get currentRoad => state.currentRoad;
  set currentRoad(int value) {
    if (state.currentRoad == value) return;
    state = state.copyWith(currentRoad: value);
  }

  bool get isFullscreen => state.isFullscreen;
  set isFullscreen(bool value) {
    if (state.isFullscreen == value) return;
    state = state.copyWith(isFullscreen: value);
  }

  bool get isPip => state.isPip;
  set isPip(bool value) {
    if (state.isPip == value) return;
    state = state.copyWith(isPip: value);
  }

  bool get showTabBody => state.showTabBody;
  set showTabBody(bool value) {
    if (state.showTabBody == value) return;
    state = state.copyWith(showTabBody: value);
  }

  int get historyOffset => state.historyOffset;
  set historyOffset(int value) {
    if (state.historyOffset == value) return;
    state = state.copyWith(historyOffset: value);
  }

  String get title => state.title;
  set title(String value) {
    if (state.title == value) return;
    state = state.copyWith(title: value);
  }

  String get src => state.src;
  set src(String value) {
    if (state.src == value) return;
    state = state.copyWith(src: value);
  }

  List<Road> get roadList => state.roadList;

  Plugin get currentPlugin {
    final plugin = state.currentPlugin;
    if (plugin == null) {
      throw StateError('currentPlugin is not set');
    }
    return plugin;
  }

  set currentPlugin(Plugin plugin) {
    state = state.copyWith(currentPlugin: plugin);
  }

  Future<void> changeEpisode(int episode,
      {int currentRoad = 0, int offset = 0}) async {
    if (state.roadList.isEmpty) {
      KazumiLogger().log(Level.warning, '尝试切换剧集时播放列表为空 episode: $episode');
      return;
    }
    if (currentRoad >= state.roadList.length) {
      KazumiLogger()
          .log(Level.warning, '尝试切换剧集时播放列表索引越界 currentRoad: $currentRoad');
      return;
    }
    if (episode <= 0 || episode > state.roadList[currentRoad].data.length) {
      KazumiLogger().log(Level.warning,
          '尝试切换剧集时集数越界 episode: $episode currentRoad: $currentRoad');
      return;
    }
    currentEpisode = episode;
    this.currentRoad = currentRoad;
    historyOffset = offset;
    final chapterName = state.roadList[currentRoad].identifier[episode - 1];
    KazumiLogger().log(Level.info, '跳转到$chapterName');
    var urlItem = state.roadList[currentRoad].data[episode - 1];
    final plugin = currentPlugin;
    if (!urlItem.contains(plugin.baseUrl) &&
        !urlItem.contains(plugin.baseUrl.replaceAll('https', 'http'))) {
      urlItem = plugin.baseUrl + urlItem;
    }
    await webviewController.loadUrl(
      urlItem,
      plugin.useNativePlayer,
      plugin.useLegacyParser,
      offset: offset,
    );
  }

  Future<void> queryBangumiEpisodeCommentsByID(int id, int episode) async {
    clearEpisodeComments();
    episodeInfo = await BangumiHTTP.getBangumiEpisodeByID(id, episode);
    final result =
        await BangumiHTTP.getBangumiCommentsByEpisodeID(episodeInfo.id);
    addEpisodeComments(result.commentList);
    KazumiLogger().log(Level.info, '已加载评论列表长度 ${state.episodeComments.length}');
  }

  Future<void> queryRoads(String url, String pluginName,
      {CancelToken? cancelToken}) async {
    cancelToken ??= CancelToken();
    _queryRoadsCancelToken?.cancel();
    _queryRoadsCancelToken = cancelToken;

    Plugin? matched;
    for (final plugin in pluginsController.pluginList) {
      if (plugin.name == pluginName) {
        matched = plugin;
        break;
      }
    }

    if (matched == null) {
      KazumiLogger().log(Level.warning, '未找到插件 $pluginName');
      state = state.copyWith(roadList: const []);
      return;
    }

    final roads =
        await matched.querychapterRoads(url, cancelToken: cancelToken);
    state = state.copyWith(roadList: List<Road>.from(roads));
    KazumiLogger().log(Level.info, '播放列表长度 ${state.roadList.length}');
    if (state.roadList.isNotEmpty) {
      KazumiLogger()
          .log(Level.info, '第一播放列表选集数 ${state.roadList.first.data.length}');
    }
  }

  void cancelQueryRoads() {
    if (_queryRoadsCancelToken != null &&
        !_queryRoadsCancelToken!.isCancelled) {
      _queryRoadsCancelToken!.cancel();
    }
    _queryRoadsCancelToken = null;
  }

  void enterFullScreen() {
    isFullscreen = true;
    showTabBody = false;
    Utils.enterFullScreen(lockOrientation: false);
  }

  void exitFullScreen() {
    isFullscreen = false;
    Utils.exitFullScreen();
  }

  Future<void> isDesktopFullscreen() async {
    if (Utils.isDesktop()) {
      isFullscreen = await windowManager.isFullScreen();
    }
  }

  void handleOnEnterFullScreen() {
    isFullscreen = true;
    showTabBody = false;
  }

  void handleOnExitFullScreen() {
    isFullscreen = false;
  }
}
