import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';

class WebviewItemImpel extends StatefulWidget {
  const WebviewItemImpel({
    super.key,
    required this.webviewController,
  });

  final WebviewItemController webviewController;

  @override
  State<WebviewItemImpel> createState() => _WebviewItemImpelState();
}

class _WebviewItemImpelState extends State<WebviewItemImpel> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    widget.webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return compositeView;
  }

  Future<void> initPlatformState() async {
    // 初始化Webview
    if (widget.webviewController.webviewController == null) {
      await widget.webviewController.init();
    }
    if (!mounted) return;
    setState(() {});
  }

  Widget get compositeView {
    if (widget.webviewController.webviewController == null) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return WebViewWidget(
          controller: widget.webviewController.webviewController);
    }
  }
}
