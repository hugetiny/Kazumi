import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';

/// Provider for flutter_inappwebview_windows initialization state
final webviewInAppWebViewWindowsInitializedProvider =
    StateProvider.autoDispose<int>((ref) => 0);

/// Windows WebView widget implementation using flutter_inappwebview_windows
/// This uses HeadlessInAppWebView, so no UI is displayed
/// The WebView runs in the background for video source parsing
class WebviewInAppWebViewWindowsItemImpel extends ConsumerStatefulWidget {
  const WebviewInAppWebViewWindowsItemImpel({
    super.key,
    required this.webviewController,
  });

  final WebviewItemController<WindowsInAppWebViewController> webviewController;

  @override
  ConsumerState<WebviewInAppWebViewWindowsItemImpel> createState() =>
      _WebviewInAppWebViewWindowsItemImpelState();
}

class _WebviewInAppWebViewWindowsItemImpelState
    extends ConsumerState<WebviewInAppWebViewWindowsItemImpel> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // Initialize WebView (headless mode, no UI needed)
    await widget.webviewController.init();
    if (!mounted) return;
    // Defer provider update to next frame to avoid potential writes during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(webviewInAppWebViewWindowsInitializedProvider.notifier).state++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to trigger rebuild when webview is initialized
    ref.watch(webviewInAppWebViewWindowsInitializedProvider);
    
    // HeadlessInAppWebView doesn't need UI, so we show a placeholder
    return Container(
      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Windows WebView (Headless Mode)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '视频源解析中...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

