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
  final MenuController _exitMenuController = MenuController();
  final MenuController _metadataLocaleMenuController = MenuController();
  final MenuController _appLocaleMenuController = MenuController();

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

  Future<void> _updateExitBehavior(int value) async {
    setState(() {
      exitBehavior = value;
    });
    await setting.put(SettingBoxKey.exitBehavior, value);
    if (_exitMenuController.isOpen) {
      _exitMenuController.close();
    }
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
    final localeController = ref.read(localeSettingsProvider.notifier);

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

    // Metadata locale options
    final List<_MetadataLocaleOption> metadataLocaleOptions =
        <_MetadataLocaleOption>[
      _MetadataLocaleOption(
        label: t.settings.metadata.followSystemLanguage,
        tag: null,
      ),
      _MetadataLocaleOption(
        label: t.settings.metadata.simplifiedChinese,
        tag: 'zh-CN',
      ),
      _MetadataLocaleOption(
        label: t.settings.metadata.traditionalChinese,
        tag: 'zh-TW',
      ),
      _MetadataLocaleOption(
        label: t.settings.metadata.japanese,
        tag: 'ja-JP',
      ),
      _MetadataLocaleOption(
        label: t.settings.metadata.english,
        tag: 'en-US',
      ),
    ];

    final _MetadataLocaleOption matchedMetadataLocale =
        metadataLocaleOptions.firstWhere(
      (option) => option.tag == metadataState.manualLocaleTag,
      orElse: () => _MetadataLocaleOption(label: '', tag: null),
    );
    final String metadataLocaleLabel = metadataState.manualLocaleTag == null
        ? metadataLocaleOptions.first.label
        : (matchedMetadataLocale.label.isNotEmpty
            ? matchedMetadataLocale.label
            : '${t.settings.metadata.custom} (${metadataState.manualLocaleTag})');

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
                  leading: const Icon(Icons.palette_rounded),
                  title: Text(t.settings.general.appearance),
                  description: Text(t.settings.general.appearanceDesc),
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    if (_appLocaleMenuController.isOpen) {
                      _appLocaleMenuController.close();
                    } else {
                      _appLocaleMenuController.open();
                    }
                  },
                  leading: const Icon(Icons.language_rounded),
                  title: Text(t.settings.general.language),
                  description: Text(t.settings.general.languageDesc),
                  value: MenuAnchor(
                    consumeOutsideTap: true,
                    controller: _appLocaleMenuController,
                    builder: (_, __, ___) {
                      return Text(appLocaleLabel);
                    },
                    menuChildren: [
                      for (final _AppLocaleOption option in appLocaleOptions)
                        MenuItemButton(
                          requestFocusOnHover: false,
                          onPressed: () async {
                            if (option.locale == null) {
                              await localeController.useSystemLocale();
                            } else {
                              await localeController.setLocale(option.locale!);
                            }
                            _appLocaleMenuController.close();
                          },
                          child: SizedBox(
                            height: 48,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option.label,
                                style: TextStyle(
                                  color: option.locale == null
                                      ? (localeState.followSystem
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null)
                                      : (!localeState.followSystem &&
                                              option.locale ==
                                                  localeState.appLocale
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isDesktop)
                  SettingsTile.navigation(
                    onPressed: (_) {
                      if (_exitMenuController.isOpen) {
                        _exitMenuController.close();
                      } else {
                        _exitMenuController.open();
                      }
                    },
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(t.settings.general.exitBehavior),
                    value: MenuAnchor(
                      consumeOutsideTap: true,
                      controller: _exitMenuController,
                      builder: (_, __, ___) {
                        return Text(exitBehaviorTitles[exitBehavior]);
                      },
                      menuChildren: [
                        for (int i = 0; i < exitBehaviorTitles.length; i++)
                          MenuItemButton(
                            requestFocusOnHover: false,
                            onPressed: () => _updateExitBehavior(i),
                            child: SizedBox(
                              height: 48,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  exitBehaviorTitles[i],
                                  style: TextStyle(
                                    color: i == exitBehavior
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                  leading: const Icon(Icons.extension),
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
                SettingsTile.navigation(
                  onPressed: (_) {
                    if (_metadataLocaleMenuController.isOpen) {
                      _metadataLocaleMenuController.close();
                    } else {
                      _metadataLocaleMenuController.open();
                    }
                  },
                  leading: const Icon(Icons.translate_rounded),
                  title: Text(t.settings.metadata.preferredLanguage),
                  description: Text(t.settings.metadata.preferredLanguageDesc),
                  value: MenuAnchor(
                    consumeOutsideTap: true,
                    controller: _metadataLocaleMenuController,
                    builder: (_, __, ___) {
                      return Text(metadataLocaleLabel);
                    },
                    menuChildren: [
                      for (final _MetadataLocaleOption option
                          in metadataLocaleOptions)
                        MenuItemButton(
                          requestFocusOnHover: false,
                          onPressed: () async {
                            await metadataController.setManualLocale(option.tag);
                            _metadataLocaleMenuController.close();
                          },
                          child: SizedBox(
                            height: 48,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option.label,
                                style: TextStyle(
                                  color: option.tag ==
                                          metadataState.manualLocaleTag
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                  leading: const Icon(Icons.display_settings_rounded),
                  title: Text(t.settings.player.playerSettings),
                  description: Text(t.settings.player.playerSettingsDesc),
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/danmaku');
                  },
                  leading: const Icon(Icons.subtitles_rounded),
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
                  leading: const Icon(Icons.cloud),
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
                  leading: const Icon(Icons.info_outline_rounded),
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

class _MetadataLocaleOption {
  const _MetadataLocaleOption({required this.label, required this.tag});

  final String label;
  final String? tag;
}
