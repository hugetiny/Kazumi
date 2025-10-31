import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/menu/navigation_provider.dart';
import 'package:kazumi/pages/setting/providers.dart';
import 'package:kazumi/pages/webdav_editor/providers.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  late final Box setting;
  late int exitBehavior;

  @override
  void initState() {
    super.initState();
    setting = GStorage.setting;
    exitBehavior =
        setting.get(SettingBoxKey.exitBehavior, defaultValue: 2) as int;
  }

  void onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
    ref.read(navigationBarControllerProvider.notifier).updateSelectedIndex(0);
    context.go('/tab/popular');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t; // Get translations
    final webDavState = ref.watch(webDavSettingsControllerProvider);
    final webDavController =
        ref.read(webDavSettingsControllerProvider.notifier);
    final metadataState = ref.watch(metadataSettingsProvider);
    final metadataController = ref.read(metadataSettingsProvider.notifier);
    final localeState = ref.watch(localeSettingsProvider);

    // Exit behavior options
    final List<String> exitBehaviorTitles = [
      t.settings.general.exitApp,
      t.settings.general.minimizeToTray,
      t.settings.general.askEveryTime,
    ];

    // App locale options
    final List<_AppLocaleOption> appLocaleOptions = [
      _AppLocaleOption(
        label: t.settings.general.followSystem,
        locale: null,
      ),
      _AppLocaleOption(
        label: '简体中文 (zh-CN)',
        locale: AppLocale.zhCn,
      ),
      _AppLocaleOption(
        label: 'English (en-US)',
        locale: AppLocale.enUs,
      ),
      _AppLocaleOption(
        label: '日本語 (ja-JP)',
        locale: AppLocale.jaJp,
      ),
      _AppLocaleOption(
        label: '繁體中文 (zh-TW)',
        locale: AppLocale.zhTw,
      ),
    ];

    final String appLocaleLabel;
    if (localeState.followSystem) {
      appLocaleLabel = appLocaleOptions.first.label;
    } else {
      appLocaleLabel = appLocaleOptions
              .firstWhere(
                (option) => option.locale == localeState.appLocale,
                orElse: () => _AppLocaleOption(
                  label: localeState.appLocale.flutterLocale.toLanguageTag(),
                  locale: localeState.appLocale,
                ),
              )
              .label;
    }

    final isDesktop = Utils.isDesktop();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(
          title: Text(t.settings.title),
          needTopOffset: false,
        ),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: Text(t.settings.general.title),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/theme');
                  },
                  title: Text(t.settings.general.appearance),
                  description: Text(t.settings.general.appearanceDesc),
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/language');
                  },
                  title: Text(t.settings.general.language),
                  description: Text(t.settings.general.languageDesc),
                  value: Text(appLocaleLabel),
                ),
                if (isDesktop)
                  SettingsTile.navigation(
                    onPressed: (_) {
                      context.push('/settings/exit-behavior');
                    },
                    title: Text(t.settings.general.exitBehavior),
                    value: Text(exitBehaviorTitles[exitBehavior]),
                  ),
              ],
            ),
            SettingsSection(
              title: Text(t.settings.source.title),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/plugin');
                  },
                  title: Text(t.settings.source.ruleManagement),
                  description: Text(t.settings.source.ruleManagementDesc),
                ),
                SettingsTile.switchTile(
                  enabled: webDavState.initialized,
                  onToggle: (value) async {
                    if (!webDavState.initialized) {
                      return;
                    }
                    await webDavController.toggleGitProxy(
                      value ?? !webDavState.enableGitProxy,
                    );
                  },
                  title: Text(t.settings.source.githubProxy),
                  description: Text(t.settings.source.githubProxyDesc),
                  initialValue: webDavState.enableGitProxy,
                ),
              ],
            ),
            SettingsSection(
              title: Text(t.settings.metadata.title),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    await metadataController.setBangumiEnabled(
                      value ?? !metadataState.bangumiEnabled,
                    );
                  },
                  title: Text(t.settings.metadata.enableBangumi),
                  description: Text(t.settings.metadata.enableBangumiDesc),
                  initialValue: metadataState.bangumiEnabled,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    await metadataController.setTmdbEnabled(
                      value ?? !metadataState.tmdbEnabled,
                    );
                  },
                  title: Text(t.settings.metadata.enableTmdb),
                  description: Text(t.settings.metadata.enableTmdbDesc),
                  initialValue: metadataState.tmdbEnabled,
                ),
              ],
            ),
            SettingsSection(
              title: Text(t.settings.player.title),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/player');
                  },
                  title: Text(t.settings.player.playerSettings),
                  description: Text(t.settings.player.playerSettingsDesc),
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/danmaku');
                  },
                  title: Text(t.settings.player.danmakuSettings),
                  description: Text(t.settings.player.danmakuSettingsDesc),
                ),
              ],
            ),
            SettingsSection(
              title: Text(t.settings.webdav.title),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/webdav');
                  },
                  title: Text(t.settings.webdav.title),
                  description: Text(t.settings.webdav.desc),
                ),
              ],
            ),
            SettingsSection(
              title: Text(t.settings.other.title),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/about');
                  },
                  title: Text(t.settings.other.about),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLocaleOption {
  const _AppLocaleOption({required this.label, required this.locale});

  final String label;
  final AppLocale? locale;
}
