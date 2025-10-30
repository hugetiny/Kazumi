import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/menu/navigation_provider.dart';
import 'package:kazumi/pages/download/providers.dart';
import 'package:kazumi/modules/download/download_task.dart';
import 'package:kazumi/pages/download/download_task_detail_dialog.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<String> _selectedGids = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'created'; // created, name, size, speed, progress
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedGids.clear();
      }
    });
  }

  void _toggleSelection(String gid) {
    setState(() {
      if (_selectedGids.contains(gid)) {
        _selectedGids.remove(gid);
      } else {
        _selectedGids.add(gid);
      }
    });
  }

  void _selectAll(List<DownloadTask> tasks) {
    setState(() {
      _selectedGids.clear();
      _selectedGids.addAll(tasks.map((t) => t.gid));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedGids.clear();
    });
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

  void _showDeleteConfirmDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除选中的下载任务吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
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
          title: _isSelectionMode
              ? Text('已选择 ${_selectedGids.length} 项')
              : const Text('下载管理'),
          needTopOffset: false,
          leading: _isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSelectionMode,
                )
              : null,
          actions: _isSelectionMode
              ? [
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () {
                      final allTasks = [
                        ...downloadState.activeTasks,
                        ...downloadState.waitingTasks,
                        ...downloadState.completedTasks,
                      ];
                      _selectAll(allTasks);
                    },
                    tooltip: '全选',
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: _selectedGids.isEmpty
                        ? null
                        : () {
                            downloadController.resumeSelected(_selectedGids.toList());
                            _toggleSelectionMode();
                          },
                    tooltip: '继续',
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: _selectedGids.isEmpty
                        ? null
                        : () {
                            downloadController.pauseSelected(_selectedGids.toList());
                            _toggleSelectionMode();
                          },
                    tooltip: '暂停',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _selectedGids.isEmpty
                        ? null
                        : () {
                            _showDeleteConfirmDialog(
                              context,
                              () {
                                downloadController.deleteSelected(_selectedGids.toList());
                                _toggleSelectionMode();
                              },
                            );
                          },
                    tooltip: '删除',
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    onPressed: _toggleSelectionMode,
                    tooltip: '批量管理',
                  ),
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'pause_all':
                          downloadController.pauseAll();
                          break;
                        case 'resume_all':
                          downloadController.resumeAll();
                          break;
                        case 'clear_completed':
                          downloadController.clearCompleted();
                          break;
                        case 'delete_all':
                          _showDeleteConfirmDialog(
                            context,
                            () => downloadController.deleteAll(),
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'pause_all',
                        child: Row(
                          children: [
                            Icon(Icons.pause),
                            SizedBox(width: 8),
                            Text('暂停全部'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'resume_all',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('继续全部'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_completed',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all),
                            SizedBox(width: 8),
                            Text('清除已完成'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除全部', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
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
            // Statistics banner (only show when downloading)
            if (downloadState.isConnected && downloadState.totalDownloading > 0)
              _buildStatisticsBanner(context, downloadState),
            // Search and sort options
            _buildSearchAndSort(context, downloadController),
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

  Widget _buildStatisticsBanner(BuildContext context, DownloadState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.speed,
            size: 20,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '总速度: ${_formatSpeed(state.totalDownloadSpeed)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
                if (state.estimatedRemainingSeconds > 0)
                  Text(
                    '预计剩余: ${_formatDuration(state.estimatedRemainingSeconds)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                  ),
              ],
            ),
          ),
          Text(
            '${state.totalDownloading} 个任务',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(BuildContext context, DownloadController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索任务名称...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(context, 'created', '创建时间'),
              _buildSortMenuItem(context, 'name', '名称'),
              _buildSortMenuItem(context, 'size', '文件大小'),
              _buildSortMenuItem(context, 'speed', '下载速度'),
              _buildSortMenuItem(context, 'progress', '进度'),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(
    BuildContext context,
    String value,
    String label,
  ) {
    final isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
          if (isSelected) const SizedBox(width: 4),
          Text(
            label,
            style: isSelected
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds 秒';
    if (seconds < 3600) return '${seconds ~/ 60} 分钟';
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    if (mins == 0) return '$hours 小时';
    return '$hours 小时 $mins 分钟';
  }

  Widget _buildDownloadingList(
    BuildContext context,
    DownloadState state,
    DownloadController controller,
  ) {
    var tasks = [...state.activeTasks, ...state.waitingTasks];
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      tasks = controller.searchTasks(_searchQuery)
          .where((t) => t.isDownloading)
          .toList();
    }
    
    // Apply sort
    tasks = controller.sortTasks(tasks, _sortBy, ascending: _sortAscending);

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
              _searchQuery.isNotEmpty ? '无搜索结果' : '暂无下载任务',
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
    var tasks = List<DownloadTask>.from(state.completedTasks);
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      tasks = controller.searchTasks(_searchQuery)
          .where((t) => t.isComplete || t.isError)
          .toList();
    }
    
    // Apply sort
    tasks = controller.sortTasks(tasks, _sortBy, ascending: _sortAscending);
    
    if (tasks.isEmpty) {
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
              _searchQuery.isNotEmpty ? '无搜索结果' : '暂无已完成任务',
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
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
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
    var allTasks = [
      ...state.activeTasks,
      ...state.waitingTasks,
      ...state.completedTasks,
    ];
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      allTasks = controller.searchTasks(_searchQuery);
    }
    
    // Apply sort
    allTasks = controller.sortTasks(allTasks, _sortBy, ascending: _sortAscending);

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
              _searchQuery.isNotEmpty ? '无搜索结果' : '暂无任务',
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
    final isSelected = _selectedGids.contains(task.gid);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: _isSelectionMode
            ? () => _toggleSelection(task.gid)
            : () {
                // Show detail dialog when not in selection mode
                showDialog(
                  context: context,
                  builder: (context) => DownloadTaskDetailDialog(
                    task: task,
                    onRetry: task.isError ? () async {
                      await controller.retryDownload(task);
                      if (context.mounted) {
                        KazumiDialog.showToast(message: '已重新添加到下载队列');
                      }
                    } : null,
                    onOpenFile: task.isComplete && task.fileName != null ? () {
                      KazumiDialog.showToast(message: '文件位置: ${task.fileName}');
                    } : null,
                  ),
                );
              },
        onLongPress: !_isSelectionMode
            ? () {
                _toggleSelectionMode();
                _toggleSelection(task.gid);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(task.gid),
                    ),
                    const SizedBox(width: 8),
                  ],
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
            if (!_isSelectionMode) ...[
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
