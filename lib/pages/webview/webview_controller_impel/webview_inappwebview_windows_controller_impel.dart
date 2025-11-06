import 'dart:async';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:kazumi/pages/webview/webview_controller.dart';
import 'package:kazumi/utils/utils.dart';

/// Windows WebView controller implementation using flutter_inappwebview_windows
/// This replaces the old webview_windows implementation with a unified approach
/// that matches Android/iOS/macOS platforms using JavaScript handlers
class WebviewInAppWebViewWindowsItemControllerImpel
    extends WebviewItemController<WindowsInAppWebViewController> {
  WindowsHeadlessInAppWebView? headlessWebView;
  Timer? loadingMonitorTimer;
  bool _isWebViewCreated = false;
  bool _useNativePlayer = false;
  bool _useLegacyParser = false;

  @override
  Future<void> init() async {
    // 🚀 优化：预先创建 WebView，避免每次重新创建
    await _ensureWebViewCreated();
    initEventController.add(true);
  }

  /// 确保 WebView 已创建（只创建一次）
  Future<void> _ensureWebViewCreated() async {
    if (_isWebViewCreated) return;

    headlessWebView = WindowsHeadlessInAppWebView(
      WindowsHeadlessInAppWebViewCreationParams(
        initialSettings: InAppWebViewSettings(
          userAgent: Utils.getRandomUA(),
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          cacheEnabled: false,
          isInspectable: false,
        ),
        onWebViewCreated: (controller) {
          webviewController = controller;
        },
        onLoadStart: (controller, url) {
          // Silent
        },
        onLoadStop: (controller, url) async {
          // 🚀 优化：每次页面加载完成都注入脚本（包括 iframe 页面）
          if (_useNativePlayer && !_useLegacyParser) {
            await _injectVideoProcessingScripts();
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          // Silent
        },
        onReceivedError: (controller, request, error) {
          logEventController.add('❌ 加载错误: ${error.description}');
        },
      ),
    );

    await headlessWebView!.run();
    _isWebViewCreated = true;
  }

  @override
  Future<void> loadUrl(String url, bool useNativePlayer, bool useLegacyParser,
      {int offset = 0}) async {
    // 保存参数供 onLoadStop 回调使用
    _useNativePlayer = useNativePlayer;
    _useLegacyParser = useLegacyParser;

    // 🚀 优化：确保 WebView 已创建（复用现有实例）
    await _ensureWebViewCreated();

    // 停止当前加载
    loadingMonitorTimer?.cancel();
    try {
      await webviewController?.stopLoading();
    } catch (e) {
      // Ignore errors
    }

    // 重置状态
    count = 0;
    this.offset = offset;
    isIframeLoaded = false;
    isVideoSourceLoaded = false;
    videoLoadingEventController.add(true);

    logEventController.add('🔍 开始解析: $url');

    // 🚀 优化：每次都重新设置 handlers（确保回调能正常工作）
    await _setupJavaScriptHandlers(useNativePlayer, useLegacyParser);

    // 🚀 优化：直接加载 URL，不重新创建 WebView
    await webviewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));

    // 注意：脚本注入现在在 onLoadStop 回调中自动执行，不需要手动延迟注入

    // Start timeout monitor (30 seconds)
    loadingMonitorTimer?.cancel();
    loadingMonitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isVideoSourceLoaded || isIframeLoaded) {
        timer.cancel();
        return;
      }
      count++;
      // Silent - only log every 5 seconds
      if (count % 5 == 0) {
        logEventController.add('⏳ 解析中... $count秒');
      }
      if (count >= 30) {
        timer.cancel();
        // Try fallback extraction
        final fallback = await _fallbackExtractSource();
        if (fallback != null && fallback.isNotEmpty) {
          logEventController.add('✅ 视频源: $fallback');
          isIframeLoaded = true;
          isVideoSourceLoaded = true;
          videoLoadingEventController.add(false);
          videoParserEventController.add((fallback, offset));

          // Delay WebView disposal to prevent crash
          Future.delayed(const Duration(milliseconds: 500), () {
            unloadPage();
          });
          return;
        }
        // Don't immediately mark as failed - wait a bit more for page load to complete
        // and iframe detection to run
        logEventController.add('⏳ 等待页面加载完成...');

        // Wait up to 5 more seconds for page load and iframe detection
        Timer(const Duration(seconds: 5), () {
          if (!isVideoSourceLoaded) {
            isVideoSourceLoaded = true;
            videoLoadingEventController.add(false);
            logEventController.add('clear');
            logEventController.add('❌ 解析视频资源超时');
            logEventController.add('💡 请切换到其他播放列表或视频源');
            logEventController.add('showDebug');
            // Note: ParseFailureHelper.recordFailure is called at a higher level (video_page.dart)
          }
        });
      }
    });
  }

  /// Setup JavaScript handlers for video source detection
  Future<void> _setupJavaScriptHandlers(bool useNativePlayer, bool useLegacyParser) async {
    if (!useNativePlayer) {
      return;
    }

    // Log bridge for debugging
    webviewController?.addJavaScriptHandler(
      handlerName: 'LogBridge',
      callback: (args) {
        if (args.isEmpty) return;
        String message = args[0].toString();

        // Only log important messages
        if (message.contains('M3U8') ||
            message.contains('视频源') ||
            message.contains('iframe') ||
            message.contains('检测到')) {
          logEventController.add(message);
        }
      },
    );

    // JSBridgeDebug: Handle iframe URLs (used in both legacy and modern modes)
    webviewController?.addJavaScriptHandler(
      handlerName: 'JSBridgeDebug',
      callback: (args) async {
        if (args.isEmpty) return;
        // Allow processing even if isIframeLoaded is true, in case we detect iframe after timeout
        String message = args[0].toString();

        // Skip if we already have a video source
        if (isVideoSourceLoaded) {
          return;
        }

        // In legacy mode, iframe URL is the video source
        if (useLegacyParser && message.contains('http')) {
          logEventController.add('✅ 视频源 (iframe): $message');
          isIframeLoaded = true;
          isVideoSourceLoaded = true;
          videoLoadingEventController.add(false);
          videoParserEventController.add((message, offset));

          // Delay WebView disposal to prevent crash
          Future.delayed(const Duration(milliseconds: 500), () {
            unloadPage();
          });
        }
        // In modern mode, we need to load the iframe URL to parse video inside it
        else if (!useLegacyParser && message.contains('http')) {
          logEventController.add('🔄 检测到 iframe，正在解析...');
          isIframeLoaded = true;

          // Navigate to iframe URL to detect video inside it
          try {
            await webviewController?.loadUrl(urlRequest: URLRequest(url: WebUri(message)));
          } catch (e) {
            logEventController.add('❌ iframe 加载失败: $e');
            // Fallback: treat iframe URL as video source
            isVideoSourceLoaded = true;
            videoLoadingEventController.add(false);
            videoParserEventController.add((message, offset));

            // Delay WebView disposal to prevent crash
            Future.delayed(const Duration(milliseconds: 500), () {
              unloadPage();
            });
          }
        }
      },
    );

    if (!useLegacyParser) {
      // Modern parser: detect video sources
      webviewController?.addJavaScriptHandler(
        handlerName: 'VideoBridgeDebug',
        callback: (args) {
          if (args.isEmpty || isVideoSourceLoaded) return;
          String message = args[0].toString();
          if (message.contains('http')) {
            isIframeLoaded = true;
            isVideoSourceLoaded = true;
            videoLoadingEventController.add(false);
            logEventController.add('✅ 视频源: $message');
            videoParserEventController.add((message, offset));

            // Delay WebView disposal to prevent crash
            // Give WebView time to finish processing current events
            Future.delayed(const Duration(milliseconds: 500), () {
              unloadPage();
            });
          }
        },
      );
    }
  }

  /// Inject user scripts for video source detection
  Future<void> _injectVideoProcessingScripts() async {
    if (webviewController == null) return;

    // Script 1: M3U8 detection via fetch (priority 1), XMLHttpRequest (priority 2), and Response.text (fallback)
    const String m3u8DetectionScript = """
      (function() {
        // Wait for flutter_inappwebview to be ready
        function waitForBridge(callback) {
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            callback();
          } else {
            window.addEventListener('flutterInAppWebViewPlatformReady', callback);
          }
        }

        waitForBridge(function() {
          // Global flag to stop further detection once video source is found
          window.__kazumi_video_found = false;

          // Priority 1: Wrap fetch to detect M3U8/MP4 early and via headers/text
          try {
            if (typeof window.fetch === 'function' && !window.__kazumi_fetch_wrapped) {
              window.__kazumi_fetch_wrapped = true;
              const _fetch = window.fetch;
              window.fetch = async function(...args) {
                // Early exit if already found
                if (window.__kazumi_video_found) {
                  return _fetch.apply(this, args);
                }

                let url = '';
                try {
                  const req = args && args[0];
                  if (typeof req === 'string') {
                    url = req;
                  } else if (req && req.url) {
                    url = req.url;
                  }
                  // Check URL pattern for M3U8/MP4
                  if (url && (url.includes('.m3u8') || url.includes('m3u8') || url.includes('.mp4'))) {
                    window.__kazumi_video_found = true;
                    window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8/MP4 (fetch URL): ' + url);
                    window.flutter_inappwebview.callHandler('VideoBridgeDebug', url);
                    return _fetch.apply(this, args);
                  }
                } catch(e){}

                const resp = await _fetch.apply(this, args);

                // Early exit if already found
                if (window.__kazumi_video_found) {
                  return resp;
                }

                try {
                  const ct = resp && resp.headers && resp.headers.get ? (resp.headers.get('content-type')||'') : '';
                  const respUrl = resp && (resp.url || url) ? (resp.url || url) : '';

                  // Check Content-Type for HLS/MP4
                  if (ct.includes('application/vnd.apple.mpegurl') || ct.includes('application/x-mpegURL') || ct.includes('video/mp4')) {
                    window.__kazumi_video_found = true;
                    window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8/MP4 (fetch content-type): ' + respUrl);
                    if (respUrl) {
                      window.flutter_inappwebview.callHandler('VideoBridgeDebug', respUrl);
                    }
                  } else {
                    // Fallback: check response text for #EXTM3U
                    try {
                      const cloned = resp.clone();
                      cloned.text().then(function(text) {
                        if (!window.__kazumi_video_found && text && text.trim().startsWith('#EXTM3U')) {
                          window.__kazumi_video_found = true;
                          window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 (fetch text): ' + respUrl);
                          window.flutter_inappwebview.callHandler('VideoBridgeDebug', respUrl);
                        }
                      }).catch(function(){});
                    } catch(e){}
                  }
                } catch(e){}

                return resp;
              };
            }
          } catch(e){}

          // Priority 2: Intercept XHR requests for M3U8 detection (only if fetch didn't find it)
          const _open = window.XMLHttpRequest.prototype.open;
          window.XMLHttpRequest.prototype.open = function (...args) {
            this.addEventListener("load", () => {
              // Early exit if already found by fetch
              if (window.__kazumi_video_found) {
                return;
              }

              try {
                // Check if the URL looks like M3U8
                const url = args[1];
                if (url && (url.includes('.m3u8') || url.includes('m3u8'))) {
                  window.__kazumi_video_found = true;
                  window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 (XHR): ' + url);
                  window.flutter_inappwebview.callHandler('VideoBridgeDebug', url);
                  return;
                }

                // Try to read response content (only if responseType allows it)
                if (this.responseType === '' || this.responseType === 'text') {
                  let content = this.responseText;
                  if (content && content.trim().startsWith("#EXTM3U")) {
                    window.__kazumi_video_found = true;
                    window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 内容 (XHR): ' + url);
                    window.flutter_inappwebview.callHandler('VideoBridgeDebug', url);
                  }
                }
              } catch (e) {
                // Silent - don't log XHR errors to avoid spam
              }
            });
            return _open.apply(this, args);
          };

          // Fallback: Intercept Response.text() to detect M3U8 content (in case fetch wrapper didn't catch it)
          const _r_text = window.Response.prototype.text;
          window.Response.prototype.text = function () {
            return new Promise((resolve, reject) => {
              _r_text.call(this).then((text) => {
                resolve(text);
                // Only check if not already found
                if (!window.__kazumi_video_found && text && text.trim().startsWith("#EXTM3U")) {
                  window.__kazumi_video_found = true;
                  window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 (Response.text): ' + this.url);
                  window.flutter_inappwebview.callHandler('VideoBridgeDebug', this.url);
                }
              }).catch(reject);
            });
          }
        });
      })();
    """;

    // Script 2: Video tag detection via MutationObserver (priority 3 - only if fetch/XHR didn't find it)
    const String videoTagDetectionScript = """
      (function() {
        // Wait for flutter_inappwebview to be ready
        function waitForBridge(callback) {
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            callback();
          } else {
            window.addEventListener('flutterInAppWebViewPlatformReady', callback);
          }
        }

        waitForBridge(function() {
          function processVideoElement(video) {
            // Early exit if already found by fetch/XHR
            if (window.__kazumi_video_found) {
              return true;
            }

            let src = video.getAttribute('src') || video.currentSrc;

            // If it's a blob URL, we need to find the iframe that contains the real source
            if (src && src.startsWith('blob:')) {
              window.flutter_inappwebview.callHandler('LogBridge', '🔄 检测到 Blob URL，查找 iframe...');
              // Don't return yet, let iframe detection handle this
            }
            // If it's a direct HTTP/HTTPS URL, use it
            else if (src && src.trim() !== '' && !src.includes('googleads')) {
              window.__kazumi_video_found = true;
              _observer.disconnect();
              window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到视频源 (<video>): ' + src);
              window.flutter_inappwebview.callHandler('VideoBridgeDebug', src);
              return true;
            }

            // Check source tags
            const sources = video.getElementsByTagName('source');
            for (let source of sources) {
              src = source.getAttribute('src') || source.src;
              if (src && src.startsWith('blob:')) {
                window.flutter_inappwebview.callHandler('LogBridge', '🔄 检测到 Blob URL (source)，查找 iframe...');
              } else if (src && src.trim() !== '' && !src.includes('googleads')) {
                window.__kazumi_video_found = true;
                _observer.disconnect();
                window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到视频源 (<video> source): ' + src);
                window.flutter_inappwebview.callHandler('VideoBridgeDebug', src);
                return true;
              }
            }
            return false;
          }

          const _observer = new MutationObserver((mutations) => {
            // Early exit if already found
            if (window.__kazumi_video_found) {
              _observer.disconnect();
              return;
            }

            for (const mutation of mutations) {
              if (mutation.type === "attributes" && mutation.target.nodeName === "VIDEO") {
                if (processVideoElement(mutation.target)) return;
                continue;
              }
              for (const node of mutation.addedNodes) {
                if (node.nodeName === "VIDEO") {
                  if (processVideoElement(node)) return;
                }
                if (node.querySelectorAll) {
                  for (const video of node.querySelectorAll("video")) {
                    if (processVideoElement(video)) return;
                  }
                }
              }
            }
          });

          function setupVideoProcessing() {
            // Check for iframes
            const iframes = document.querySelectorAll('iframe');
            if (iframes.length > 0) {
              window.flutter_inappwebview.callHandler('LogBridge', '🔍 检测到 ' + iframes.length + ' 个 iframe');
            }

            // If we found iframes, send their src to JSBridgeDebug handler (for legacy parser compatibility)
            for (let i = 0; i < iframes.length; i++) {
              const iframe = iframes[i];
              let src = iframe.getAttribute('src');

              // Skip empty or ad-related iframes
              if (!src || src.trim() === '' ||
                  src.includes('googleads') || src.includes('adtrafficquality') ||
                  src.includes('googlesyndication.com') || src.includes('google.com') ||
                  src.includes('prestrain.html') || src.includes('prestrain%2Ehtml')) {
                continue;
              }

              // Convert relative URL to absolute URL
              if (!src.startsWith('http') && !src.startsWith('//')) {
                // Relative URL - convert to absolute
                if (src.startsWith('/')) {
                  src = window.location.origin + src;
                } else {
                  src = window.location.origin + '/' + src;
                }
              } else if (src.startsWith('//')) {
                // Protocol-relative URL
                src = window.location.protocol + src;
              }

              window.flutter_inappwebview.callHandler('LogBridge', '🔄 检测到 iframe: ' + src);
              window.flutter_inappwebview.callHandler('JSBridgeDebug', src);
            }

            // Check for video tags (only if not already found)
            if (!window.__kazumi_video_found) {
              const videos = document.querySelectorAll("video");
              for (const video of videos) {
                if (processVideoElement(video)) return;
              }

              _observer.observe(document.body, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ['src']
              });
            }
          }

          if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', setupVideoProcessing);
          } else {
            setupVideoProcessing();
          }
        });
      })();
    """;

    // Script 3: Inject video detection into iframes
    const String iframeVideoDetectionScript = """
      (function() {
        function waitForBridge(callback) {
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            callback();
          } else {
            window.addEventListener('flutterInAppWebViewPlatformReady', callback);
          }
        }

        waitForBridge(function() {
          function injectIntoIframe(iframe) {
            try {
              const iframeWindow = iframe.contentWindow;
              if (!iframeWindow) {
                return;
              }

              // Wrap fetch inside iframe (priority 1 within iframe)
              try {
                if (typeof iframeWindow.fetch === 'function' && !iframeWindow.__kazumi_fetch_wrapped) {
                  iframeWindow.__kazumi_fetch_wrapped = true;
                  const _iframe_fetch = iframeWindow.fetch;
                  iframeWindow.fetch = async function (...args) {
                    // Early exit if already found by other layers
                    if (window.__kazumi_video_found) {
                      return _iframe_fetch.apply(this, args);
                    }

                    let url = '';
                    try {
                      const req = args && args[0];
                      if (typeof req === 'string') {
                        url = req;
                      } else if (req && req.url) {
                        url = req.url;
                      }
                      if (url && (url.includes('.m3u8') || url.includes('m3u8') || url.includes('.mp4'))) {
                        window.__kazumi_video_found = true;
                        window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8/MP4 (iframe fetch URL): ' + url);
                        window.flutter_inappwebview.callHandler('VideoBridgeDebug', url);
                        return _iframe_fetch.apply(this, args);
                      }
                    } catch (e) {}

                    const resp = await _iframe_fetch.apply(this, args);

                    if (window.__kazumi_video_found) {
                      return resp;
                    }

                    try {
                      const ct = resp && resp.headers && resp.headers.get ? (resp.headers.get('content-type') || '') : '';
                      const respUrl = resp && (resp.url || url) ? (resp.url || url) : '';
                      if (ct.includes('application/vnd.apple.mpegurl') || ct.includes('application/x-mpegURL') || ct.includes('video/mp4')) {
                        window.__kazumi_video_found = true;
                        window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8/MP4 (iframe fetch content-type): ' + respUrl);
                        if (respUrl) {
                          window.flutter_inappwebview.callHandler('VideoBridgeDebug', respUrl);
                        }
                      } else {
                        try {
                          const cloned = resp.clone();
                          cloned.text().then(function (text) {
                            if (!window.__kazumi_video_found && text && text.trim().startsWith('#EXTM3U')) {
                              window.__kazumi_video_found = true;
                              window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 (iframe fetch text): ' + respUrl);
                              window.flutter_inappwebview.callHandler('VideoBridgeDebug', respUrl);
                            }
                          }).catch(function () { });
                        } catch (e) { }
                      }
                    } catch (e) { }

                    return resp;
                  };
                }
              } catch (e) { }

              // Intercept XHR in iframe for M3U8 detection
              const iframe_open = iframeWindow.XMLHttpRequest.prototype.open;
              iframeWindow.XMLHttpRequest.prototype.open = function (...args) {
                this.addEventListener("load", () => {
                  try {
                    // Check if the URL looks like M3U8
                    const url = args[1];
                    if (url && (url.includes('.m3u8') || url.includes('m3u8'))) {
                      window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 (iframe): ' + url);
                      window.flutter_inappwebview.callHandler('VideoBridgeDebug', url);
                      return;
                    }

                    // Try to read response content (only if responseType allows it)
                    if (this.responseType === '' || this.responseType === 'text') {
                      let content = this.responseText;
                      if (content && content.trim().startsWith("#EXTM3U")) {
                        window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 内容 (iframe): ' + url);
                        window.flutter_inappwebview.callHandler('VideoBridgeDebug', url);
                      }
                    }
                  } catch (e) {
                    // Silent - don't log XHR errors to avoid spam
                  }
                });
                return iframe_open.apply(this, args);
              };

              // Intercept Fetch in iframe for M3U8 detection
              const iframe_r_text = iframeWindow.Response.prototype.text;
              iframeWindow.Response.prototype.text = function () {
                return new Promise((resolve, reject) => {
                  iframe_r_text.call(this).then((text) => {
                    resolve(text);
                    if (text.trim().startsWith("#EXTM3U")) {
                      window.flutter_inappwebview.callHandler('LogBridge', '🎬 检测到 M3U8 (iframe Fetch): ' + this.url);
                      window.flutter_inappwebview.callHandler('VideoBridgeDebug', this.url);
                    }
                  }).catch(reject);
                });
              };
            } catch (e) {
              // Silent - cross-origin iframes cannot be accessed
            }
          }

          function setupIframeListeners() {
            document.querySelectorAll('iframe').forEach(iframe => {
              if (iframe.contentDocument) {
                injectIntoIframe(iframe);
              }
              iframe.addEventListener('load', () => injectIntoIframe(iframe));
            });

            const observer = new MutationObserver(mutations => {
              mutations.forEach(mutation => {
                if (mutation.type === 'childList') {
                  mutation.addedNodes.forEach(node => {
                    if (node.nodeName === 'IFRAME') {
                      node.addEventListener('load', () => injectIntoIframe(node));
                    }
                    if (node.querySelectorAll) {
                      node.querySelectorAll('iframe').forEach(iframe => {
                        iframe.addEventListener('load', () => injectIntoIframe(iframe));
                      });
                    }
                  });
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }

          if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', setupIframeListeners);
          } else {
            setupIframeListeners();
          }
        });
      })();
    """;

    try {
      await webviewController!.evaluateJavascript(source: m3u8DetectionScript);
      await webviewController!.evaluateJavascript(source: videoTagDetectionScript);
      await webviewController!.evaluateJavascript(source: iframeVideoDetectionScript);
    } catch (e) {
      logEventController.add('❌ 脚本注入失败: $e');
    }
  }

  /// Fallback extraction using DOM queries
  Future<String?> _fallbackExtractSource() async {
    if (webviewController == null) return null;
    try {
      final result = await webviewController!.evaluateJavascript(source: r'''
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
          }catch(e){}
          return '';
        })();
      ''');
      if (result != null && result.toString().isNotEmpty && result.toString() != 'null') {
        return result.toString().replaceAll(RegExp(r'^"|"$'), '');
      }
    } catch (e) {
      // Silent - fallback failed
    }
    return null;
  }

  @override
  Future<void> unloadPage() async {
    loadingMonitorTimer?.cancel();

    // 🚀 优化：不销毁 WebView，只是停止加载并导航到 about:blank
    try {
      await webviewController?.stopLoading();
      await webviewController?.loadUrl(urlRequest: URLRequest(url: WebUri('about:blank')));
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  void dispose() {
    loadingMonitorTimer?.cancel();
    _isWebViewCreated = false;

    // Clear references
    final tempWebView = headlessWebView;
    final tempController = webviewController;
    headlessWebView = null;
    webviewController = null;

    // Dispose WebView with error handling
    if (tempWebView != null) {
      try {
        // Try to stop loading first
        tempController?.stopLoading();
      } catch (e) {
        // Ignore errors
      }

      try {
        tempWebView.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    }
  }
}
