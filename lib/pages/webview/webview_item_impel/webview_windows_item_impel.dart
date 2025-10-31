import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';

/// Provider for webview windows initialization state
final webviewWindowsInitializedProvider = StateProvider.autoDispose<int>((ref) => 0);

class WebviewWindowsItemImpel extends ConsumerStatefulWidget {
  const WebviewWindowsItemImpel({
    super.key,
    required this.webviewController,
    required this.videoPageController,
  });

  final WebviewItemController<WebviewController> webviewController;
  final VideoPageController videoPageController;

  @override
  ConsumerState<WebviewWindowsItemImpel> createState() =>
      _WebviewWindowsItemImpelState();
}

class _WebviewWindowsItemImpelState extends ConsumerState<WebviewWindowsItemImpel> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    for (var s in _subscriptions) {
      try {
        s.cancel();
      } catch (_) {}
    }
    widget.webviewController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // 初始化Webview
    if (widget.webviewController.webviewController == null) {
      await widget.webviewController.init();
    }
    // 接受全屏事件
    final controller = widget.webviewController.webviewController;
    if (controller != null) {
      _subscriptions.add(controller.containsFullScreenElementChanged
          .listen((flag) {
        widget.videoPageController.isFullscreen = flag;
        windowManager.setFullScreen(flag);
      }));
    }
    if (!mounted) return;

    ref.read(webviewWindowsInitializedProvider.notifier).state++;
  }

  Widget get compositeView {
    final controller = widget.webviewController.webviewController;
    if (controller == null) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Webview(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to trigger rebuild when webview is initialized
    ref.watch(webviewWindowsInitializedProvider);
    return compositeView;
  }
}
