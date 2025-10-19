import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/webdav.dart';

class WebDavSettingsState {
  final bool enableGitProxy;
  final bool webDavEnable;
  final bool webDavEnableHistory;
  final bool initialized;
  final bool isBusy;

  const WebDavSettingsState({
    this.enableGitProxy = false,
    this.webDavEnable = false,
    this.webDavEnableHistory = false,
    this.initialized = false,
    this.isBusy = false,
  });

  WebDavSettingsState copyWith({
    bool? enableGitProxy,
    bool? webDavEnable,
    bool? webDavEnableHistory,
    bool? initialized,
    bool? isBusy,
  }) {
    return WebDavSettingsState(
      enableGitProxy: enableGitProxy ?? this.enableGitProxy,
      webDavEnable: webDavEnable ?? this.webDavEnable,
      webDavEnableHistory: webDavEnableHistory ?? this.webDavEnableHistory,
      initialized: initialized ?? this.initialized,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

class WebDavActionResult {
  final bool success;
  final String message;

  const WebDavActionResult({required this.success, required this.message});
}

class WebDavSettingsController extends SafeStateNotifier<WebDavSettingsState> {
  WebDavSettingsController() : super(const WebDavSettingsState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final setting = GStorage.setting;
    final enableGitProxy =
        setting.get(SettingBoxKey.enableGitProxy, defaultValue: false) as bool;
    final webDavEnable =
        setting.get(SettingBoxKey.webDavEnable, defaultValue: false) as bool;
    final webDavEnableHistory = setting
            .get(SettingBoxKey.webDavEnableHistory, defaultValue: false)
        as bool;

    state = state.copyWith(
      enableGitProxy: enableGitProxy,
      webDavEnable: webDavEnable,
      webDavEnableHistory: webDavEnable ? webDavEnableHistory : false,
      initialized: true,
    );
  }

  Future<void> refreshFromStorage() async {
    await _loadFromStorage();
  }

  Future<void> toggleGitProxy(bool value) async {
    final setting = GStorage.setting;
    await setting.put(SettingBoxKey.enableGitProxy, value);
    state = state.copyWith(enableGitProxy: value);
  }

  Future<WebDavActionResult> toggleWebDav(bool value) async {
    final setting = GStorage.setting;
    if (value) {
      try {
        if (!WebDav().initialized) {
          await WebDav().init();
        }
      } catch (e) {
        await setting.put(SettingBoxKey.webDavEnable, false);
        state = state.copyWith(webDavEnable: false);
        return WebDavActionResult(
          success: false,
          message: 'WEBDAV初始化失败 $e',
        );
      }
    }

    if (!value) {
      await setting.put(SettingBoxKey.webDavEnableHistory, false);
    }

    await setting.put(SettingBoxKey.webDavEnable, value);
    state = state.copyWith(
      webDavEnable: value,
      webDavEnableHistory: value ? state.webDavEnableHistory : false,
    );

    return const WebDavActionResult(success: true, message: '');
  }

  Future<WebDavActionResult> toggleWebDavHistory(bool value) async {
    if (!state.webDavEnable) {
      state = state.copyWith();
      return const WebDavActionResult(
        success: false,
        message: '请先开启WEBDAV同步',
      );
    }

    final setting = GStorage.setting;
    await setting.put(SettingBoxKey.webDavEnableHistory, value);
    state = state.copyWith(webDavEnableHistory: value);

    return const WebDavActionResult(success: true, message: '');
  }

  Future<WebDavActionResult> updateWebDav() async {
    if (!state.webDavEnable) {
      return const WebDavActionResult(
        success: false,
        message: '未开启WebDav同步或配置无效',
      );
    }

    state = state.copyWith(isBusy: true);
    try {
      final webDav = WebDav();
      if (!webDav.initialized) {
        await webDav.init();
      }
      try {
        await webDav.ping();
      } catch (_) {
        return const WebDavActionResult(
          success: false,
          message: 'WebDAV连接失败',
        );
      }

      try {
        await webDav.updateHistory();
        return const WebDavActionResult(success: true, message: '同步成功');
      } catch (e) {
        return WebDavActionResult(
          success: false,
          message: '同步失败 $e',
        );
      }
    } catch (e) {
      return WebDavActionResult(
        success: false,
        message: '同步失败 $e',
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<WebDavActionResult> downloadWebDav() async {
    if (!state.webDavEnable) {
      return const WebDavActionResult(
        success: false,
        message: '未开启WebDav同步或配置无效',
      );
    }

    state = state.copyWith(isBusy: true);
    try {
      final webDav = WebDav();
      if (!webDav.initialized) {
        await webDav.init();
      }
      try {
        await webDav.ping();
      } catch (_) {
        return const WebDavActionResult(
          success: false,
          message: 'WebDAV连接失败',
        );
      }

      try {
        await webDav.downloadAndPatchHistory();
        return const WebDavActionResult(success: true, message: '同步成功');
      } catch (e) {
        return WebDavActionResult(
          success: false,
          message: '同步失败 $e',
        );
      }
    } catch (e) {
      return WebDavActionResult(
        success: false,
        message: '同步失败 $e',
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }
}

final webDavSettingsControllerProvider =
    StateNotifierProvider<WebDavSettingsController, WebDavSettingsState>(
  (ref) => WebDavSettingsController(),
);
