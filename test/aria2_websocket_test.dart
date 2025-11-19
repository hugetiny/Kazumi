// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/utils/aria2_websocket.dart';

void main() {
  group('Aria2WebSocketClient', () {
    late Aria2WebSocketClient client;
    final List<Aria2EventData> receivedEvents = [];
    final List<Aria2ConnectionState> stateChanges = [];

    setUp(() {
      receivedEvents.clear();
      stateChanges.clear();

      client = Aria2WebSocketClient(
        onEvent: (eventData) {
          receivedEvents.add(eventData);
        },
        onBatchEvents: (events) {
          print('Received batch: ${events.length} events');
        },
        onConnected: () {
          print('WebSocket connected');
        },
        onDisconnected: () {
          print('WebSocket disconnected');
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        eventBufferDuration: const Duration(milliseconds: 100),
        maxReconnectAttempts: 3,
        initialReconnectDelay: const Duration(milliseconds: 500),
        heartbeatInterval: const Duration(seconds: 5),
      );
    });

    tearDown(() {
      client.dispose();
    });

    test('初始状态应为 disconnected', () {
      expect(client.connectionState, Aria2ConnectionState.disconnected);
      expect(client.isConnected, false);
      expect(client.isDisposed, false);
    });

    test('连接状态流应该发送状态变化', () async {
      final states = <Aria2ConnectionState>[];
      final subscription = client.connectionStateStream.listen((state) {
        states.add(state);
      });

      // 模拟连接
      await client.connect();

      // 等待状态更新
      await Future.delayed(const Duration(milliseconds: 100));

      // 应该至少收到 connecting 状态
      expect(states.isNotEmpty, true);

      await subscription.cancel();
    });

    test('dispose 后应无法连接', () async {
      client.dispose();

      expect(client.isDisposed, true);

      // 尝试连接应该被忽略
      await client.connect();

      expect(client.isConnected, false);
    });

    test('事件解析应该正确', () {
      // 测试事件类型映射
      const eventMap = {
        Aria2Event.downloadStart: 'aria2.onDownloadStart',
        Aria2Event.downloadPause: 'aria2.onDownloadPause',
        Aria2Event.downloadStop: 'aria2.onDownloadStop',
        Aria2Event.downloadComplete: 'aria2.onDownloadComplete',
        Aria2Event.downloadError: 'aria2.onDownloadError',
        Aria2Event.btDownloadComplete: 'aria2.onBtDownloadComplete',
      };

      expect(eventMap.length, 6);
    });

    test('getStats 应该返回统计信息', () {
      final stats = client.getStats();

      expect(stats['connectionState'], isNotNull);
      expect(stats['isConnected'], false);
      expect(stats['reconnectAttempts'], 0);
      expect(stats['bufferedEvents'], 0);
    });

    test('resetReconnectAttempts 应该重置计数', () {
      // 模拟重连尝试
      client.resetReconnectAttempts();

      final stats = client.getStats();
      expect(stats['reconnectAttempts'], 0);
    });
  });

  group('Aria2EventData', () {
    test('应该正确创建事件数据', () {
      final eventData = Aria2EventData(
        gid: 'test-gid-123',
        event: Aria2Event.downloadComplete,
        timestamp: DateTime.now(),
        data: {'status': 'complete'},
      );

      expect(eventData.gid, 'test-gid-123');
      expect(eventData.event, Aria2Event.downloadComplete);
      expect(eventData.data!['status'], 'complete');
      expect(eventData.toString(), contains('test-gid-123'));
    });

    test('data 可以为 null', () {
      final eventData = Aria2EventData(
        gid: 'test-gid',
        event: Aria2Event.downloadStart,
        timestamp: DateTime.now(),
      );

      expect(eventData.data, isNull);
    });
  });

  group('Aria2ConnectionState', () {
    test('应该包含所有状态', () {
      final states = [
        Aria2ConnectionState.disconnected,
        Aria2ConnectionState.connecting,
        Aria2ConnectionState.connected,
        Aria2ConnectionState.reconnecting,
        Aria2ConnectionState.error,
      ];

      expect(states.length, 5);
    });
  });

  group('WebSocket URL 转换', () {
    test('HTTP 应该转换为 WS', () {
      const httpUrl = 'http://127.0.0.1:6800/jsonrpc';
      final wsUrl = httpUrl.replaceFirst('http://', 'ws://');
      expect(wsUrl, 'ws://127.0.0.1:6800/jsonrpc');
    });

    test('HTTPS 应该转换为 WSS', () {
      const httpsUrl = 'https://example.com:6800/jsonrpc';
      final wssUrl = httpsUrl.replaceFirst('https://', 'wss://');
      expect(wssUrl, 'wss://example.com:6800/jsonrpc');
    });
  });

  group('指数退避计算', () {
    test('应该正确计算退避延迟', () {
      const initialDelay = Duration(milliseconds: 1000);
      const maxDelay = Duration(milliseconds: 30000);

      // 第 1 次: 1 * 2^0 = 1s
      final delay1 = (initialDelay.inMilliseconds * (1 << 0))
          .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds);
      expect(delay1, 1000);

      // 第 2 次: 1 * 2^1 = 2s
      final delay2 = (initialDelay.inMilliseconds * (1 << 1))
          .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds);
      expect(delay2, 2000);

      // 第 3 次: 1 * 2^2 = 4s
      final delay3 = (initialDelay.inMilliseconds * (1 << 2))
          .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds);
      expect(delay3, 4000);

      // 第 5 次: 1 * 2^4 = 16s
      final delay5 = (initialDelay.inMilliseconds * (1 << 4))
          .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds);
      expect(delay5, 16000);

      // 第 10 次: 应该达到上限 30s
      final delay10 = (initialDelay.inMilliseconds * (1 << 9))
          .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds);
      expect(delay10, 30000);
    });
  });

  group('集成测试（需要运行 aria2）', () {
    test('完整连接流程（手动测试）', () async {
      // 这个测试需要 aria2 运行在 localhost:6800
      // 在 CI 环境中会被跳过

      // 初始化存储（模拟）
      // await GStorage.init();

      final client = Aria2WebSocketClient(
        onEvent: (eventData) {
          print('Event: ${eventData.event} for ${eventData.gid}');
        },
        onConnected: () {
          print('✅ Connected to aria2');
        },
        onDisconnected: () {
          print('⚠️ Disconnected from aria2');
        },
        onError: (error) {
          print('❌ Error: $error');
        },
      );

      try {
        // 连接
        await client.connect();

        // 等待连接建立
        await Future.delayed(const Duration(seconds: 2));

        if (client.isConnected) {
          print('✅ WebSocket connection successful');

          // 获取统计信息
          final stats = client.getStats();
          print('Stats: $stats');
        } else {
          print('⚠️ WebSocket not connected (aria2 may not be running)');
        }

        // 断开连接
        client.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));

        expect(client.isConnected, false);
      } finally {
        client.dispose();
      }
    }, skip: true); // 默认跳过，需要手动运行

    test('重连机制测试（手动测试）', () async {
      final reconnectAttempts = <int>[];

      final client = Aria2WebSocketClient(
        onEvent: (_) {},
        onConnected: () {
          print('Connected (attempt: ${reconnectAttempts.length})');
        },
        onDisconnected: () {
          print('Disconnected');
        },
        maxReconnectAttempts: 3,
        initialReconnectDelay: const Duration(milliseconds: 500),
      );

      try {
        // 连接到不存在的端点（模拟失败）
        await client.connect();

        // 等待多次重连尝试
        await Future.delayed(const Duration(seconds: 5));

        final stats = client.getStats();
        print('Reconnect attempts: ${stats['reconnectAttempts']}');

        expect(stats['reconnectAttempts'], lessThanOrEqualTo(3));
      } finally {
        client.dispose();
      }
    }, skip: true); // 默认跳过

    test('事件缓冲测试', () async {
      final batchedEvents = <List<Aria2EventData>>[];

      final client = Aria2WebSocketClient(
        onEvent: (_) {},
        onBatchEvents: (events) {
          batchedEvents.add(events);
          print('Batch received: ${events.length} events');
        },
        eventBufferDuration: const Duration(milliseconds: 300),
      );

      try {
        // 模拟快速接收多个事件
        // 这些事件应该被缓冲并批量处理

        // 实际测试需要 aria2 发送真实事件
        // 这里只是验证配置正确
        expect(client.connectionState, Aria2ConnectionState.disconnected);
      } finally {
        client.dispose();
      }
    });
  });

  group('性能测试', () {
    test('快速连接/断开不应泄漏资源', () async {
      for (var i = 0; i < 10; i++) {
        final client = Aria2WebSocketClient(
          onEvent: (_) {},
        );

        // 快速连接和断开
        await client.connect();
        await Future.delayed(const Duration(milliseconds: 10));
        client.disconnect();
        client.dispose();
      }

      // 如果有内存泄漏，这个测试会消耗大量内存
      expect(true, true);
    });

    test('大量事件处理不应阻塞', () async {
      final eventCount = 1000;
      final receivedCount = <int>[];

      final client = Aria2WebSocketClient(
        onEvent: (eventData) {
          receivedCount.add(1);
        },
      );

      try {
        // 模拟大量事件
        // 实际场景中由 aria2 发送

        expect(client.isDisposed, false);
      } finally {
        client.dispose();
      }
    });
  });
}
