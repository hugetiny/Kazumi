import 'dart:async';
import 'package:webview_windows/webview_windows.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';

class WebviewWindowsItemControllerImpel
    extends WebviewItemController<WebviewController> {
  final List<StreamSubscription> subscriptions = [];
  // Guard flags to prevent double-initialization/races when rapidly switching pages
  bool _initialized = false;
  Future<void>? _initFuture;
  Timer? loadingMonitorTimer;

  // Attempt a last-chance extraction using DOM queries for <video>/<source>/links
  Future<String?> _fallbackExtractSource() async {
    if (webviewController == null) return null;
    try {
      final String result = await webviewController!.executeScript(r'''
        (function(){
          function pick(u){
            if(!u) return '';
            try{
              var url = u.toString();
              if(url.startsWith('blob:')) return '';
              if(url.startsWith('//')) url = window.location.protocol + url;
              if(url.startsWith('http')) return url;
              return '';
            }catch(e){return '';}
          }
          try{
            var videos = document.querySelectorAll('video');
            for (var i=0;i<videos.length;i++){
              var src = videos[i].currentSrc || videos[i].getAttribute('src');
              src = pick(src);
              if(src) return src;
            }
            var sources = document.querySelectorAll('source');
            for (var i=0;i<sources.length;i++){
              var s = sources[i].src || sources[i].getAttribute('src');
              s = pick(s);
              if(s) return s;
            }
            var as = document.querySelectorAll('a[href]');
            for (var i=0;i<as.length;i++){
              var href = as[i].href;
              href = pick(href);
              if(href && (href.indexOf('.m3u8')>-1 || href.indexOf('.mp4')>-1)) return href;
            }
          }catch(e){}
          return '';
        })();
      ''');
      if (result.isNotEmpty && result != '""' && result != 'null') {
        // Some engines wrap the result in quotes; strip them if present
        final sanitized = result.replaceAll(RegExp(r'^"|"$'), '');
        return sanitized;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> init() async {
    // If already initialized, simply return without re-emitting the init event
    // to avoid triggering episode reload loops.
    if (_initialized) {
      return;
    }

    // If an initialization is already in-flight, await the same future
    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    // Start initialization (idempotent)
    _initFuture = () async {
      webviewController ??= WebviewController();
      await webviewController!.initialize();
      await webviewController!
          .setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      _initialized = true;
      // Emit initialized event only once, when initialization completes
      initEventController.add(true);
    }();

    try {
      await _initFuture;
    } finally {
      // Clear the future handle after completion to allow re-init after dispose
      _initFuture = null;
    }
  }

  @override
  Future<void> loadUrl(String url, bool useNativePlayer, bool useLegacyParser,
      {int offset = 0}) async {
    await unloadPage();
    // Always ensure initialization is complete before interacting with controller
    await init();
    count = 0;
    this.offset = offset;
    isIframeLoaded = false;
    isVideoSourceLoaded = false;
    videoLoadingEventController.add(true);

    logEventController.add('[Windows WebView] 开始解析: $url');
    logEventController.add('[Windows WebView] 使用原生播放器: $useNativePlayer');
    logEventController.add('[Windows WebView] 使用传统解析: $useLegacyParser');

    // Start timeout monitor (15 seconds like other platforms)
    loadingMonitorTimer?.cancel();
    loadingMonitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isVideoSourceLoaded || isIframeLoaded) {
        timer.cancel();
        return;
      }
      count++;
      logEventController.add('[Windows WebView] 解析中... $count秒');
      if (count >= 15) {
        timer.cancel();
        // Try a one-time fallback extraction to improve compatibility
        final fallback = await _fallbackExtractSource();
        if (fallback != null && fallback.isNotEmpty) {
          logEventController.add('[Windows WebView] Fallback 解析命中: $fallback');
          unloadPage();
          isIframeLoaded = true;
          isVideoSourceLoaded = true;
          videoLoadingEventController.add(false);
          videoParserEventController.add((fallback, offset));
          return;
        }
        isVideoSourceLoaded = true;
        videoLoadingEventController.add(false);
        logEventController.add('clear');
        logEventController.add('解析视频资源超时 (15秒)');
        logEventController.add('可能原因:');
        logEventController.add('1. 视频源不支持 Windows WebView 解析');
        logEventController.add('2. 插件规则可能不适配该视频网站');
        logEventController.add('3. 网站使用了特殊加密或反爬虫机制');
        logEventController.add('建议: 切换到其他播放列表或视频源');
        logEventController.add('showDebug');
      }
    });

    subscriptions.add(webviewController!.onM3USourceLoaded.listen((data) {
      String url = data['url'] ?? '';
      logEventController.add('[Windows WebView] M3U源事件触发: $url');
      if (url.isEmpty) {
        logEventController.add('[Windows WebView] M3U源URL为空，忽略');
        return;
      }
      unloadPage();
      isIframeLoaded = true;
      isVideoSourceLoaded = true;
      videoLoadingEventController.add(false);
      logEventController.add('Loading m3u8 source: $url');
      videoParserEventController.add((url, offset));
    }));
    subscriptions.add(webviewController!.onVideoSourceLoaded.listen((data) {
      String url = data['url'] ?? '';
      logEventController.add('[Windows WebView] 视频源事件触发: $url');
      if (url.isEmpty) {
        logEventController.add('[Windows WebView] 视频源URL为空，忽略');
        return;
      }
      unloadPage();
      isIframeLoaded = true;
      isVideoSourceLoaded = true;
      videoLoadingEventController.add(false);
      logEventController.add('Loading video source: $url');
      videoParserEventController.add((url, offset));
    }));
    logEventController.add('[Windows WebView] 事件监听已注册');
    await webviewController!.loadUrl(url);
    logEventController.add('[Windows WebView] loadUrl 调用完成');
  }

  @override
  Future<void> unloadPage() async {
    loadingMonitorTimer?.cancel();
    if (webviewController == null) {
      subscriptions.clear();
      return;
    }
    for (final s in subscriptions) {
      try {
        s.cancel();
      } catch (_) {}
    }
    subscriptions.clear();
    await redirect2Blank();
  }

  @override
  void dispose() {
    loadingMonitorTimer?.cancel();
    for (final s in subscriptions) {
      try {
        s.cancel();
      } catch (_) {}
    }
    subscriptions.clear();
    try {
      webviewController?.dispose();
    } catch (_) {}
    webviewController = null;
    _initialized = false;
    _initFuture = null;
  }

  // The webview_windows package does not have a method to unload the current page.
  // The loadUrl method opens a new tab, which can lead to memory leaks.
  // Directly disposing of the webview controller would require reinitialization when switching episodes, which is costly.
  // Therefore, this method is used to redirect to a blank page instead.
  Future<void> redirect2Blank() async {
    if (webviewController == null) {
      return;
    }
    try {
      await webviewController!.executeScript('''
        window.location.href = 'about:blank';
      ''');
    } catch (_) {}
  }
}
