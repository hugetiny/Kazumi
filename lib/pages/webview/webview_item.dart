import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';
import 'package:kazumi/pages/webview/webview_controller_impel/webview_android_controller_impel.dart';
import 'package:kazumi/pages/webview/webview_item_impel/webview_android_item_impel.dart';
import 'package:kazumi/pages/webview/webview_item_impel/webview_item_impel.dart';
import 'package:kazumi/pages/webview/webview_item_impel/webview_windows_item_impel.dart';
import 'package:kazumi/pages/webview/webview_item_impel/webview_linux_item_impel.dart';
import 'package:kazumi/pages/webview/webview_item_impel/webview_apple_item_impel.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:webview_windows/webview_windows.dart';

class WebviewItem extends StatefulWidget {
  const WebviewItem({
    super.key,
    required this.videoPageController,
    required this.webviewController,
  });

  final VideoPageController videoPageController;
  final WebviewItemController webviewController;

  @override
  State<WebviewItem> createState() => _WebviewItemState();
}

class _WebviewItemState extends State<WebviewItem> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WebviewWindowsItemImpel(
        webviewController:
            widget.webviewController as WebviewItemController<WebviewController>,
        videoPageController: widget.videoPageController,
      );
    }
    if (Platform.isLinux) {
      return WebviewLinuxItemImpel(
        webviewController: widget.webviewController,
      );
    }
    if (Platform.isMacOS || Platform.isIOS) {
      return WebviewAppleItemImpel(
        webviewController: widget.webviewController,
      );
    }
    if (Platform.isAndroid && Utils.isDocumentStartScriptSupported) {
      return WebviewAndroidItemImpel(
        webviewController: widget.webviewController
            as WebviewAndroidItemControllerImpel,
      );
    }
    return WebviewItemImpel(
      webviewController: widget.webviewController,
    );
  }
}
