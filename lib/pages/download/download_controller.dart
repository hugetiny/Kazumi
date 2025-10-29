import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/modules/download/download_task.dart';
import 'package:kazumi/utils/aria2_client.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

class DownloadState {
  final List<DownloadTask> activeTasks;
  final List<DownloadTask> waitingTasks;
  final List<DownloadTask> completedTasks;
  final bool isLoading;
  final String? errorMessage;
  final bool isConnected;

  const DownloadState({
    this.activeTasks = const [],
    this.waitingTasks = const [],
    this.completedTasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isConnected = false,
  });

  DownloadState copyWith({
    List<DownloadTask>? activeTasks,
    List<DownloadTask>? waitingTasks,
    List<DownloadTask>? completedTasks,
    bool? isLoading,
    String? errorMessage,
    bool? isConnected,
  }) {
    return DownloadState(
      activeTasks: activeTasks ?? this.activeTasks,
      waitingTasks: waitingTasks ?? this.waitingTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  int get totalDownloading => activeTasks.length + waitingTasks.length;
  int get totalCompleted => completedTasks.length;
}

class DownloadController extends StateNotifier<DownloadState> {
  DownloadController() : super(const DownloadState()) {
    _initialize();
  }

  Timer? _syncTimer;
  final KazumiLogger _logger = KazumiLogger();
  Aria2Client? _aria2Client;

  Future<void> _initialize() async {
    try {
      _aria2Client = Aria2Client.fromSettings();
      await _loadFromStorage();
      await refreshDownloads();
      _startPeriodicSync();
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Initialization failed: $e');
      state = state.copyWith(
        errorMessage: '初始化失败: $e',
        isConnected: false,
      );
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final box = GStorage.downloadTasks;
      final List<DownloadTask> tasks = [];
      for (var key in box.keys) {
        final task = box.get(key);
        if (task is DownloadTask) {
          tasks.add(task);
        }
      }

      final active = tasks.where((t) => t.isActive).toList();
      final waiting = tasks.where((t) => t.isWaiting || t.isPaused).toList();
      final completed =
          tasks.where((t) => t.isComplete || t.isError).toList();

      state = state.copyWith(
        activeTasks: active,
        waitingTasks: waiting,
        completedTasks: completed,
      );
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Load from storage failed: $e');
    }
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      refreshDownloads();
    });
  }

  Future<void> refreshDownloads() async {
    if (_aria2Client == null) {
      _aria2Client = Aria2Client.fromSettings();
    }

    try {
      final activeResults = await _aria2Client!.tellActive();
      final waitingResults = await _aria2Client!.tellWaiting(0, 100);
      final stoppedResults = await _aria2Client!.tellStopped(0, 100);

      final List<DownloadTask> activeTasks = [];
      final List<DownloadTask> waitingTasks = [];
      final List<DownloadTask> completedTasks = [];

      final box = GStorage.downloadTasks;

      for (var result in activeResults) {
        if (result is Map<String, dynamic>) {
          final gid = result['gid'] as String?;
          if (gid != null) {
            DownloadTask? existingTask = box.get(gid);
            final task = DownloadTask.fromAria2Status(
              result,
              title: existingTask?.title,
              bangumiId: existingTask?.bangumiId,
              episodeNumber: existingTask?.episodeNumber,
            );
            activeTasks.add(task);
            await box.put(gid, task);
          }
        }
      }

      for (var result in waitingResults) {
        if (result is Map<String, dynamic>) {
          final gid = result['gid'] as String?;
          if (gid != null) {
            DownloadTask? existingTask = box.get(gid);
            final task = DownloadTask.fromAria2Status(
              result,
              title: existingTask?.title,
              bangumiId: existingTask?.bangumiId,
              episodeNumber: existingTask?.episodeNumber,
            );
            waitingTasks.add(task);
            await box.put(gid, task);
          }
        }
      }

      for (var result in stoppedResults) {
        if (result is Map<String, dynamic>) {
          final gid = result['gid'] as String?;
          if (gid != null) {
            DownloadTask? existingTask = box.get(gid);
            final task = DownloadTask.fromAria2Status(
              result,
              title: existingTask?.title,
              bangumiId: existingTask?.bangumiId,
              episodeNumber: existingTask?.episodeNumber,
            );
            completedTasks.add(task);
            await box.put(gid, task);
          }
        }
      }

      state = state.copyWith(
        activeTasks: activeTasks,
        waitingTasks: waitingTasks,
        completedTasks: completedTasks,
        isConnected: true,
        errorMessage: null,
      );
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Refresh failed: $e');
      state = state.copyWith(
        errorMessage: 'aria2连接失败',
        isConnected: false,
      );
    }
  }

  Future<void> addDownload(
    String url, {
    String? title,
    String? bangumiId,
    int? episodeNumber,
    Map<String, dynamic>? options,
  }) async {
    if (_aria2Client == null) {
      _aria2Client = Aria2Client.fromSettings();
    }

    try {
      final gid = await _aria2Client!.addUri([url], options: options);
      if (gid != null) {
        final task = DownloadTask(
          gid: gid,
          url: url,
          title: title ?? url,
          status: 'waiting',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          bangumiId: bangumiId,
          episodeNumber: episodeNumber,
        );

        await GStorage.downloadTasks.put(gid, task);
        await refreshDownloads();
      }
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Add download failed: $e');
      state = state.copyWith(errorMessage: '添加下载失败: $e');
    }
  }

  Future<void> pauseDownload(String gid) async {
    if (_aria2Client == null) return;

    try {
      await _aria2Client!.pause(gid);
      await refreshDownloads();
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Pause failed: $e');
      state = state.copyWith(errorMessage: '暂停失败');
    }
  }

  Future<void> resumeDownload(String gid) async {
    if (_aria2Client == null) return;

    try {
      await _aria2Client!.resume(gid);
      await refreshDownloads();
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Resume failed: $e');
      state = state.copyWith(errorMessage: '恢复失败');
    }
  }

  Future<void> removeDownload(String gid, {bool force = false}) async {
    if (_aria2Client == null) return;

    try {
      await _aria2Client!.remove(gid, force: force);
      await GStorage.downloadTasks.delete(gid);
      await refreshDownloads();
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Remove failed: $e');
      state = state.copyWith(errorMessage: '删除失败');
    }
  }

  Future<void> clearCompleted() async {
    if (_aria2Client == null) return;

    try {
      await _aria2Client!.purgeCompleted();
      
      final box = GStorage.downloadTasks;
      final keysToDelete = <String>[];
      for (var key in box.keys) {
        final task = box.get(key);
        if (task is DownloadTask && (task.isComplete || task.isError)) {
          keysToDelete.add(key);
        }
      }
      
      for (var key in keysToDelete) {
        await box.delete(key);
      }

      await refreshDownloads();
    } catch (e) {
      _logger.log(Level.error, '[DownloadController] Clear completed failed: $e');
      state = state.copyWith(errorMessage: '清除失败');
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
