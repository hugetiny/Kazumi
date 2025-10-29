import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/webdav_editor/providers.dart';

class WebDavSettingsPage extends ConsumerWidget {
  const WebDavSettingsPage({super.key});

  void _dismissDialogIfNeeded() {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(webDavSettingsControllerProvider);
    final controller = ref.read(webDavSettingsControllerProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool _, Object? __) {
        _dismissDialogIfNeeded();
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('同步设置')),
        body: !state.initialized
            ? const Center(child: CircularProgressIndicator())
            : SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: const Text('WebDAV'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final result = await controller.toggleWebDav(
                      value ?? !state.webDavEnable,
                    );
                    if (!result.success && result.message.isNotEmpty) {
                      KazumiDialog.showToast(message: result.message);
                    }
                  },
                  title: const Text('WebDAV 同步'),
                  initialValue: state.webDavEnable,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final result = await controller.toggleWebDavHistory(
                      value ?? !state.webDavEnableHistory,
                    );
                    if (!result.success && result.message.isNotEmpty) {
                      KazumiDialog.showToast(message: result.message);
                    }
                  },
                  title: const Text('观看记录同步'),
                  description: const Text('允许自动同步观看记录'),
                  initialValue: state.webDavEnableHistory,
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/webdav/editor');
                  },
                  title: const Text('WebDAV 配置'),
                ),
              ],
            ),
            SettingsSection(
              bottomInfo: const Text('立即将观看记录上传到 WebDAV。'),
              tiles: [
                SettingsTile(
                  trailing: const Icon(Icons.cloud_upload_rounded),
                  onPressed: (_) async {
                    if (state.isBusy) {
                      return;
                    }
                    KazumiDialog.showToast(message: '正在尝试上传到 WebDAV…');
                    final result = await controller.updateWebDav();
                    KazumiDialog.showToast(message: result.message);
                  },
                  title: const Text('手动上传'),
                ),
              ],
            ),
            SettingsSection(
              bottomInfo: const Text('立即将观看记录同步到本地。'),
              tiles: [
                SettingsTile(
                  trailing: const Icon(Icons.cloud_download_rounded),
                  onPressed: (_) async {
                    if (state.isBusy) {
                      return;
                    }
                    KazumiDialog.showToast(message: '正在尝试从 WebDAV 同步…');
                    final result = await controller.downloadWebDav();
                    KazumiDialog.showToast(message: result.message);
                  },
                  title: const Text('手动下载'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
