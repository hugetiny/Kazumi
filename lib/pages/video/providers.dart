import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/video/video_state.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/pages/webview/providers.dart';

final videoControllerProvider =
    StateNotifierProvider<VideoPageController, VideoPageState>((ref) {
  final pluginsController = ref.read(pluginsControllerProvider.notifier);
  final webviewController = ref.read(webviewItemControllerProvider);
  final controller = VideoPageController(
    pluginsController: pluginsController,
    webviewController: webviewController,
  );
  ref.onDispose(() {
    controller.cancelQueryRoads();
  });
  return controller;
});