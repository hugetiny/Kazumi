import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/download/providers.dart';
import 'package:kazumi/utils/aria2_websocket.dart';

/// Aria2 连接状态指示器
///
/// 展示 WebSocket 连接状态、统计信息和下载速度
class Aria2ConnectionIndicator extends ConsumerWidget {
  const Aria2ConnectionIndicator({
    super.key,
    this.showDetails = false,
    this.compact = false,
  });

  final bool showDetails;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(aria2ConnectionStateProvider);
    final totalSpeed = ref.watch(totalDownloadSpeedProvider);
    final activeCount = ref.watch(activeDownloadsCountProvider);
    final waitingCount = ref.watch(waitingDownloadsCountProvider);

    if (compact) {
      return _buildCompactIndicator(
        context,
        connectionState,
        totalSpeed,
        activeCount,
      );
    }

    return _buildFullIndicator(
      context,
      connectionState,
      totalSpeed,
      activeCount,
      waitingCount,
      showDetails,
    );
  }

  Widget _buildCompactIndicator(
    BuildContext context,
    Aria2ConnectionState connectionState,
    int totalSpeed,
    int activeCount,
  ) {
    final color = _getConnectionColor(connectionState);
    final icon = _getConnectionIcon(connectionState);

    return Tooltip(
      message: _getConnectionTooltip(connectionState),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          if (activeCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatSpeed(totalSpeed),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullIndicator(
    BuildContext context,
    Aria2ConnectionState connectionState,
    int totalSpeed,
    int activeCount,
    int waitingCount,
    bool showDetails,
  ) {
    final color = _getConnectionColor(connectionState);
    final icon = _getConnectionIcon(connectionState);
    final statusText = _getConnectionStatusText(connectionState);

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 连接状态图标
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),

            // 状态文本和速度
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (activeCount > 0)
                  Text(
                    _formatSpeed(totalSpeed),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),

            // 任务计数
            if (activeCount > 0 || waitingCount > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeCount / $waitingCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],

            // 详细信息按钮
            if (showDetails) ...[
              const SizedBox(width: 8),
              Icon(Icons.info_outline, size: 16, color: color.withValues(alpha: 0.7)),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConnectionColor(Aria2ConnectionState state) {
    switch (state) {
      case Aria2ConnectionState.connected:
        return Colors.green;
      case Aria2ConnectionState.connecting:
        return Colors.blue;
      case Aria2ConnectionState.reconnecting:
        return Colors.orange;
      case Aria2ConnectionState.disconnected:
        return Colors.grey;
      case Aria2ConnectionState.error:
        return Colors.red;
    }
  }

  IconData _getConnectionIcon(Aria2ConnectionState state) {
    switch (state) {
      case Aria2ConnectionState.connected:
        return Icons.cloud_done;
      case Aria2ConnectionState.connecting:
        return Icons.cloud_sync;
      case Aria2ConnectionState.reconnecting:
        return Icons.cloud_queue;
      case Aria2ConnectionState.disconnected:
        return Icons.cloud_off;
      case Aria2ConnectionState.error:
        return Icons.error_outline;
    }
  }

  String _getConnectionStatusText(Aria2ConnectionState state) {
    switch (state) {
      case Aria2ConnectionState.connected:
        return '已连接';
      case Aria2ConnectionState.connecting:
        return '连接中...';
      case Aria2ConnectionState.reconnecting:
        return '重连中...';
      case Aria2ConnectionState.disconnected:
        return '未连接';
      case Aria2ConnectionState.error:
        return '连接错误';
    }
  }

  String _getConnectionTooltip(Aria2ConnectionState state) {
    switch (state) {
      case Aria2ConnectionState.connected:
        return 'aria2 WebSocket 已连接';
      case Aria2ConnectionState.connecting:
        return 'aria2 WebSocket 连接中';
      case Aria2ConnectionState.reconnecting:
        return 'aria2 WebSocket 重新连接中';
      case Aria2ConnectionState.disconnected:
        return 'aria2 WebSocket 未连接';
      case Aria2ConnectionState.error:
        return 'aria2 WebSocket 连接错误';
    }
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    }
  }
}

/// Aria2 连接统计信息对话框
class Aria2StatsDialog extends ConsumerWidget {
  const Aria2StatsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(aria2StatsProvider);
    final downloadState = ref.watch(downloadControllerProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.analytics_outlined),
          SizedBox(width: 8),
          Text('aria2 连接统计'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(
              'WebSocket 状态',
              _formatConnectionState(downloadState.wsConnectionState),
              _getConnectionColor(downloadState.wsConnectionState),
            ),
            const Divider(),
            _buildStatRow(
              'HTTP 连接',
              downloadState.isConnected ? '正常' : '断开',
              downloadState.isConnected ? Colors.green : Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              '活动任务',
              '${downloadState.activeTasks.length}',
              Colors.blue,
            ),
            _buildStatRow(
              '等待任务',
              '${downloadState.waitingTasks.length}',
              Colors.orange,
            ),
            _buildStatRow(
              '已完成',
              '${downloadState.completedTasks.length}',
              Colors.green,
            ),
            const Divider(),
            _buildStatRow(
              '总下载速度',
              _formatSpeed(downloadState.totalDownloadSpeed),
              Colors.purple,
            ),
            if (stats != null) ...[
              const Divider(),
              _buildStatRow(
                '重连尝试',
                '${stats['reconnectAttempts'] ?? 0}',
                Colors.orange,
              ),
              if (stats['lastMessageReceived'] != null)
                _buildStatRow(
                  '最后消息',
                  _formatTimestamp(stats['lastMessageReceived'] as String),
                  Colors.grey,
                ),
              if (stats['bufferedEvents'] != null &&
                  stats['bufferedEvents'] > 0)
                _buildStatRow(
                  '缓冲事件',
                  '${stats['bufferedEvents']}',
                  Colors.amber,
                ),
            ],
            if (downloadState.lastSyncTime != null) ...[
              const Divider(),
              _buildStatRow(
                '最后同步',
                _formatTimestamp(downloadState.lastSyncTime!.toIso8601String()),
                Colors.grey,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(downloadControllerProvider.notifier).manualRefresh();
          },
          child: const Text('手动刷新'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatConnectionState(Aria2ConnectionState state) {
    switch (state) {
      case Aria2ConnectionState.connected:
        return '已连接';
      case Aria2ConnectionState.connecting:
        return '连接中';
      case Aria2ConnectionState.reconnecting:
        return '重连中';
      case Aria2ConnectionState.disconnected:
        return '未连接';
      case Aria2ConnectionState.error:
        return '错误';
    }
  }

  Color _getConnectionColor(Aria2ConnectionState state) {
    switch (state) {
      case Aria2ConnectionState.connected:
        return Colors.green;
      case Aria2ConnectionState.connecting:
        return Colors.blue;
      case Aria2ConnectionState.reconnecting:
        return Colors.orange;
      case Aria2ConnectionState.disconnected:
        return Colors.grey;
      case Aria2ConnectionState.error:
        return Colors.red;
    }
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    }
  }

  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds} 秒前';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} 分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} 小时前';
      } else {
        return '${difference.inDays} 天前';
      }
    } catch (e) {
      return '未知';
    }
  }
}
