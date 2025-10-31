import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/menu/navigation_provider.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

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
    final t = context.t;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(title: Text(t.library.my.title), needTopOffset: false),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: Text(t.library.my.sections.video),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) => context.push('/my/favorites'),
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: Text(t.library.my.favorites.title),
                  description: Text(t.library.my.favorites.description),
                ),
                SettingsTile.navigation(
                  onPressed: (_) => context.push('/my/history'),
                  leading: const Icon(Icons.history_rounded),
                  title: Text(t.library.my.history.title),
                  description: Text(t.library.my.history.description),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
