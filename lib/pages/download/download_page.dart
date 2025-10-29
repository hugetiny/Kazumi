import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/menu/navigation_provider.dart';
import 'package:kazumi/pages/download/providers.dart';
import 'package:kazumi/modules/download/download_task.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
    ref.read(navigationBarControllerProvider.notifier).updateSelectedIndex(0);
    context.go('/tab/popular');
  }

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

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadControllerProvider);
    final downloadController = ref.read(downloadControllerProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(
          title: const Text('下载管理'),
          needTopOffset: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push('/settings/download');
              },
              tooltip: '下载设置',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                downloadController.refreshDownloads();
              },
              tooltip: '刷新',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: '下载中 (${downloadState.totalDownloading})',
              ),
              Tab(
                text: '已完成 (${downloadState.totalCompleted})',
              ),
              Tab(
                text: '全部',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            if (downloadState.errorMessage != null)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.errorContainer,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        downloadState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Downloading tab
                  _buildDownloadingList(
                    context,
                    downloadState,
                    downloadController,
                  ),
                  // Completed tab
                  _buildCompletedList(
                    context,
                    downloadState,
                    downloadController,
                  ),
                  // All tab
                  _buildAllList(
                    context,
                    downloadState,
                    downloadController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadingList(
    BuildContext context,
    DownloadState state,
    DownloadController controller,
  ) {
    final tasks = [...state.activeTasks, ...state.waitingTasks];

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无下载任务',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildDownloadItem(context, task, controller, isActive: true);
      },
    );
  }

  Widget _buildCompletedList(
    BuildContext context,
    DownloadState state,
    DownloadController controller,
  ) {
    if (state.completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无已完成任务',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  controller.clearCompleted();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('清除全部'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.completedTasks.length,
            itemBuilder: (context, index) {
              final task = state.completedTasks[index];
              return _buildDownloadItem(context, task, controller,
                  isActive: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllList(
    BuildContext context,
    DownloadState state,
    DownloadController controller,
  ) {
    final allTasks = [
      ...state.activeTasks,
      ...state.waitingTasks,
      ...state.completedTasks,
    ];

    if (allTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无任务',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: allTasks.length,
      itemBuilder: (context, index) {
        final task = allTasks[index];
        return _buildDownloadItem(
          context,
          task,
          controller,
          isActive: task.isDownloading,
        );
      },
    );
  }

  Widget _buildDownloadItem(
    BuildContext context,
    DownloadTask task,
    DownloadController controller, {
    required bool isActive,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(context, task),
              ],
            ),
            if (task.fileName != null) ...[
              const SizedBox(height: 4),
              Text(
                task.fileName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            if (isActive) ...[
              LinearProgressIndicator(
                value: task.progress,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatFileSize(task.completedLength)} / ${_formatFileSize(task.totalLength)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _formatSpeed(task.downloadSpeed),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ] else if (task.isComplete) ...[
              Text(
                '大小: ${_formatFileSize(task.totalLength)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (task.isError && task.errorMessage != null) ...[
              Text(
                '错误: ${task.errorMessage}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (task.isActive)
                  TextButton.icon(
                    onPressed: () => controller.pauseDownload(task.gid),
                    icon: const Icon(Icons.pause),
                    label: const Text('暂停'),
                  ),
                if (task.isPaused)
                  TextButton.icon(
                    onPressed: () => controller.resumeDownload(task.gid),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('继续'),
                  ),
                if (task.isError)
                  TextButton.icon(
                    onPressed: () => controller.resumeDownload(task.gid),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                TextButton.icon(
                  onPressed: () =>
                      controller.removeDownload(task.gid, force: true),
                  icon: const Icon(Icons.delete),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, DownloadTask task) {
    Color backgroundColor;
    Color foregroundColor;
    String label;

    if (task.isActive) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
      label = '下载中';
    } else if (task.isWaiting) {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;
      label = '等待中';
    } else if (task.isPaused) {
      backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
      foregroundColor = Theme.of(context).colorScheme.onTertiaryContainer;
      label = '已暂停';
    } else if (task.isComplete) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
      label = '已完成';
    } else if (task.isError) {
      backgroundColor = Theme.of(context).colorScheme.errorContainer;
      foregroundColor = Theme.of(context).colorScheme.onErrorContainer;
      label = '错误';
    } else {
      backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      foregroundColor = Theme.of(context).colorScheme.onSurface;
      label = task.status;
    }

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: foregroundColor,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
