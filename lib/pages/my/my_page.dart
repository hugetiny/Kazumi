import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/menu/navigation_provider.dart';
import 'package:kazumi/utils/aria2_feature_manager.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  void _onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
    ref.read(navigationBarControllerProvider.notifier).updateSelectedIndex(0);
    context.go('/tab/popular');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _onBackPressed(context);
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('我的'), needTopOffset: false),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: const Text('视频'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) => context.push('/my/favorites'),
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: const Text('收藏'),
                  description: const Text('查看在看、想看、看过'),
                ),
                SettingsTile.navigation(
                  onPressed: (_) => context.push('/my/history'),
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('播放历史记录'),
                  description: const Text('查看播放过的番剧'),
                ),
                // Conditionally show download management if aria2 is available
                if (Aria2FeatureManager().isAvailable)
                  SettingsTile.navigation(
                    onPressed: (_) => context.push('/my/download'),
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('下载管理'),
                    description: const Text('管理下载任务'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
