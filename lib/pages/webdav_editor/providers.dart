import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/webdav.dart';
import 'package:kazumi/providers/translations_provider.dart';

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

class WebDavSettingsController extends Notifier<WebDavSettingsState> {
  @override
  WebDavSettingsState build() => _loadStateFromStorage();

  WebDavSettingsState _loadStateFromStorage() {
    final setting = GStorage.setting;
    final enableGitProxy =
        setting.get(SettingBoxKey.enableGitProxy, defaultValue: false) as bool;
    final webDavEnable =
        setting.get(SettingBoxKey.webDavEnable, defaultValue: false) as bool;
    final webDavEnableHistory =
        setting.get(SettingBoxKey.webDavEnableHistory, defaultValue: false)
            as bool;

    return WebDavSettingsState(
      enableGitProxy: enableGitProxy,
      webDavEnable: webDavEnable,
      webDavEnableHistory: webDavEnable ? webDavEnableHistory : false,
      initialized: true,
    );
  }

  Future<void> refreshFromStorage() async {
    state = _loadStateFromStorage();
  }

  Future<void> toggleGitProxy(bool value) async {
    final setting = GStorage.setting;
    await setting.put(SettingBoxKey.enableGitProxy, value);
    state = state.copyWith(enableGitProxy: value);
  }

  Future<WebDavActionResult> toggleWebDav(bool value) async {
    final setting = GStorage.setting;
    final t = ref.read(translationsProvider);
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
          message: t.settings.webdav.result.initFailed
              .replaceFirst('{error}', e.toString()),
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
    final t = ref.read(translationsProvider);
    if (!state.webDavEnable) {
      state = state.copyWith();
      return WebDavActionResult(
        success: false,
        message: t.settings.webdav.result.requireEnable,
      );
    }

    final setting = GStorage.setting;
    await setting.put(SettingBoxKey.webDavEnableHistory, value);
    state = state.copyWith(webDavEnableHistory: value);

    return const WebDavActionResult(success: true, message: '');
  }

  Future<WebDavActionResult> updateWebDav() async {
    final t = ref.read(translationsProvider);
    if (!state.webDavEnable) {
      return WebDavActionResult(
        success: false,
        message: t.settings.webdav.result.disabled,
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
        return WebDavActionResult(
          success: false,
          message: t.settings.webdav.result.connectionFailed,
        );
      }

      try {
        await webDav.updateHistory();
        return WebDavActionResult(
          success: true,
          message: t.settings.webdav.result.syncSuccess,
        );
      } catch (e) {
        return WebDavActionResult(
          success: false,
          message: t.settings.webdav.result.syncFailed
              .replaceFirst('{error}', e.toString()),
        );
      }
    } catch (e) {
      return WebDavActionResult(
        success: false,
        message: t.settings.webdav.result.syncFailed
            .replaceFirst('{error}', e.toString()),
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<WebDavActionResult> downloadWebDav() async {
    final t = ref.read(translationsProvider);
    if (!state.webDavEnable) {
      return WebDavActionResult(
        success: false,
        message: t.settings.webdav.result.disabled,
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
        return WebDavActionResult(
          success: false,
          message: t.settings.webdav.result.connectionFailed,
        );
      }

      try {
        await webDav.downloadAndPatchHistory();
        return WebDavActionResult(
          success: true,
          message: t.settings.webdav.result.syncSuccess,
        );
      } catch (e) {
        return WebDavActionResult(
          success: false,
          message: t.settings.webdav.result.syncFailed
              .replaceFirst('{error}', e.toString()),
        );
      }
    } catch (e) {
      return WebDavActionResult(
        success: false,
        message: t.settings.webdav.result.syncFailed
            .replaceFirst('{error}', e.toString()),
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }
}

final webDavSettingsControllerProvider =
    NotifierProvider<WebDavSettingsController, WebDavSettingsState>(
  WebDavSettingsController.new,
);
