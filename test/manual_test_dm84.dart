/// Manual test script for DM84 video parsing
/// 
/// This script helps you manually test the two DM84 video parsing scenarios.
/// Run this with: flutter run -d windows -t test/manual_test_dm84.dart
/// 
/// Test URLs:
/// 1. Direct HTTP: https://dm84.net/p/1371-1-1.html
/// 2. Blob + Iframe: https://dm84.net/p/71-1-1147.html

import 'package:flutter/material.dart';
import 'package:kazumi/pages/webview/webview_controller_impel/webview_inappwebview_windows_controller_impel.dart';

void main() {
  runApp(const DM84TestApp());
}

class DM84TestApp extends StatelessWidget {
  const DM84TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DM84 Video Parser Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DM84TestPage(),
    );
  }
}

class DM84TestPage extends StatefulWidget {
  const DM84TestPage({super.key});

  @override
  State<DM84TestPage> createState() => _DM84TestPageState();
}

class _DM84TestPageState extends State<DM84TestPage> {
  final controller = WebviewInAppWebViewWindowsItemControllerImpel();
  final List<String> logs = [];
  String? detectedVideoUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _setupController() {
    // Listen to log events
    controller.logEventController.stream.listen((log) {
      setState(() {
        logs.add(log);
        // Auto-scroll to bottom
        if (logs.length > 100) {
          logs.removeAt(0);
        }
      });
    });

    // Listen to video parser events
    controller.videoParserEventController.stream.listen((event) {
      setState(() {
        detectedVideoUrl = event.$1;
        isLoading = false;
      });
    });

    // Listen to video loading events
    controller.videoLoadingEventController.stream.listen((loading) {
      setState(() {
        isLoading = loading;
      });
    });

    // Initialize controller
    controller.init();
  }

  Future<void> _testUrl(String url, String testName) async {
    setState(() {
      logs.clear();
      detectedVideoUrl = null;
      isLoading = true;
    });

    logs.add('=== Starting Test: $testName ===');
    logs.add('URL: $url');
    logs.add('');

    await controller.loadUrl(
      url,
      true, // useNativePlayer
      false, // useLegacyParser
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DM84 Video Parser Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Test buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _testUrl(
                            'https://dm84.net/p/1371-1-1.html',
                            'Test Case 1: Direct HTTP Video',
                          ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Case 1: Direct HTTP Video'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _testUrl(
                            'https://dm84.net/p/71-1-1147.html',
                            'Test Case 2: Blob URL + Iframe',
                          ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Case 2: Blob URL + Iframe'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const LinearProgressIndicator()
                else if (detectedVideoUrl != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Video Source Detected!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          detectedVideoUrl!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Logs',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              logs.clear();
                            });
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        Color? textColor;
                        FontWeight? fontWeight;

                        if (log.contains('Error') || log.contains('Failed')) {
                          textColor = Colors.red;
                        } else if (log.contains('Success') ||
                            log.contains('found') ||
                            log.contains('detected')) {
                          textColor = Colors.green.shade700;
                        } else if (log.startsWith('===')) {
                          fontWeight = FontWeight.bold;
                          textColor = Colors.blue.shade700;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: SelectableText(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: textColor,
                              fontWeight: fontWeight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

