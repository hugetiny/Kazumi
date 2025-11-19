import 'package:flutter_riverpod/flutter_riverpod.dart';

// DownloadSettingsState 类用于存储下载设置页面的所有状态
class DownloadSettingsState {
  final String aria2Status;
  final bool isTestingConnection;
  final String connectionStatus;
  final bool isUpdating;
  final bool isRestartingAria2;
  final bool isCheckingUpdate;
  final dynamic updateInfo; // Aria2UpdateInfo类型
  final bool isDownloadingUpdate;

  DownloadSettingsState({
    this.aria2Status = '',
    this.isTestingConnection = false,
    this.connectionStatus = '',
    this.isUpdating = false,
    this.isRestartingAria2 = false,
    this.isCheckingUpdate = false,
    this.updateInfo,
    this.isDownloadingUpdate = false,
  });

  DownloadSettingsState copyWith({
    String? aria2Status,
    bool? isTestingConnection,
    String? connectionStatus,
    bool? isUpdating,
    bool? isRestartingAria2,
    bool? isCheckingUpdate,
    dynamic updateInfo,
    bool? isDownloadingUpdate,
  }) {
    return DownloadSettingsState(
      aria2Status: aria2Status ?? this.aria2Status,
      isTestingConnection: isTestingConnection ?? this.isTestingConnection,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isUpdating: isUpdating ?? this.isUpdating,
      isRestartingAria2: isRestartingAria2 ?? this.isRestartingAria2,
      isCheckingUpdate: isCheckingUpdate ?? this.isCheckingUpdate,
      updateInfo: updateInfo,
      isDownloadingUpdate: isDownloadingUpdate ?? this.isDownloadingUpdate,
    );
  }
}

// DownloadSettingsNotifier 类用于管理下载设置页面的状态
class DownloadSettingsNotifier extends Notifier<DownloadSettingsState> {
  @override
  DownloadSettingsState build() {
    return DownloadSettingsState();
  }

  void setAria2Status(String status) {
    state = state.copyWith(aria2Status: status);
  }

  void setTestingConnection(bool value) {
    state = state.copyWith(isTestingConnection: value);
  }

  void setConnectionStatus(String status) {
    state = state.copyWith(connectionStatus: status);
  }

  void setUpdating(bool value) {
    state = state.copyWith(isUpdating: value);
  }

  void setIsRestartingAria2(bool isRestarting) {
    state = state.copyWith(isRestartingAria2: isRestarting);
  }

  void setIsCheckingUpdate(bool isChecking) {
    state = state.copyWith(isCheckingUpdate: isChecking);
  }

  void setUpdateInfo(dynamic info) {
    state = state.copyWith(updateInfo: info);
  }

  void setIsDownloadingUpdate(bool isDownloading) {
    state = state.copyWith(isDownloadingUpdate: isDownloading);
  }
}

// 定义downloadSettingsProvider
final downloadSettingsProvider = NotifierProvider<DownloadSettingsNotifier, DownloadSettingsState>(
  () => DownloadSettingsNotifier(),
);
