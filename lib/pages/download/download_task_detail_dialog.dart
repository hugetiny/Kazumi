import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazumi/modules/download/download_task.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';

class DownloadTaskDetailDialog extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenFile;

  const DownloadTaskDetailDialog({
    super.key,
    required this.task,
    this.onRetry,
    this.onOpenFile,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatSpeed(int bytesPerSecond) {
    return '${_formatFileSize(bytesPerSecond)}/s';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds 秒';
    if (seconds < 3600) return '${seconds ~/ 60} 分钟';
    return '${seconds ~/ 3600} 小时 ${(seconds % 3600) ~/ 60} 分钟';
  }

  String _getStatusText() {
    switch (task.status) {
      case 'active':
        return '下载中';
      case 'waiting':
        return '等待中';
      case 'paused':
        return '已暂停';
      case 'error':
        return '失败';
      case 'complete':
        return '已完成';
      case 'removed':
        return '已删除';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (task.status) {
      case 'active':
        return Colors.blue;
      case 'waiting':
        return Colors.orange;
      case 'paused':
        return Colors.grey;
      case 'error':
        return Colors.red;
      case 'complete':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int remainingBytes = task.totalLength - task.completedLength;
    final int etaSeconds = task.downloadSpeed > 0
        ? remainingBytes ~/ task.downloadSpeed
        : 0;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '任务详情',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status chip
                    Chip(
                      label: Text(_getStatusText()),
                      backgroundColor: _getStatusColor(context).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    _buildSection('任务名称', task.title),
                    const SizedBox(height: 16),

                    // File info
                    if (task.fileName != null) ...[
                      _buildSection('文件名', task.fileName!),
                      const SizedBox(height: 16),
                    ],

                    // Download info
                    _buildSection('文件大小', _formatFileSize(task.totalLength)),
                    const SizedBox(height: 8),
                    _buildSection('已下载', _formatFileSize(task.completedLength)),
                    const SizedBox(height: 8),
                    _buildSection(
                      '进度',
                      '${(task.progress * 100).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 16),

                    // Speed and ETA
                    if (task.isActive) ...[
                      _buildSection('下载速度', _formatSpeed(task.downloadSpeed)),
                      const SizedBox(height: 8),
                      if (etaSeconds > 0)
                        _buildSection('预计剩余时间', _formatDuration(etaSeconds)),
                      const SizedBox(height: 16),
                    ],

                    // URL
                    _buildSection(
                      'URL',
                      task.url,
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: task.url));
                          KazumiDialog.showToast(message: '已复制到剪贴板');
                        },
                        tooltip: '复制链接',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error info
                    if (task.isError) ...[
                      _buildSection(
                        '错误信息',
                        task.errorMessage ?? '未知错误',
                        isError: true,
                      ),
                      if (task.errorCode != null) ...[
                        const SizedBox(height: 8),
                        _buildSection(
                          '错误代码',
                          task.errorCode.toString(),
                          isError: true,
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],

                    // Bangumi info
                    if (task.bangumiId != null) ...[
                      _buildSection('番剧 ID', task.bangumiId!),
                      const SizedBox(height: 8),
                    ],
                    if (task.episodeNumber != null) ...[
                      _buildSection('集数', '第 ${task.episodeNumber} 集'),
                      const SizedBox(height: 16),
                    ],

                    // Timestamps
                    _buildSection(
                      '创建时间',
                      _formatDateTime(task.createdAt),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      '更新时间',
                      _formatDateTime(task.updatedAt),
                    ),
                    const SizedBox(height: 8),
                    _buildSection('任务 GID', task.gid),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (task.isError && onRetry != null) ...[
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry?.call();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (task.isComplete && onOpenFile != null) ...[
                    FilledButton.icon(
                      icon: const Icon(Icons.folder_open),
                      label: const Text('打开文件'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onOpenFile?.call();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String label,
    String value, {
    Widget? trailing,
    bool isError = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isError ? Colors.red : null,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isError ? Colors.red : null,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
