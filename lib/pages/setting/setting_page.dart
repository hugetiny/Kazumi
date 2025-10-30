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
import 'package:kazumi/utils/aria2_feature_manager.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  final exitBehaviorTitles = <String>['退出 Kazumi', '最小化至托盘', '每次都询问'];
  late final Box setting;
  late int exitBehavior;
  final MenuController _exitMenuController = MenuController();
  final MenuController _metadataLocaleMenuController = MenuController();

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
    final webDavState = ref.watch(webDavSettingsControllerProvider);
    final webDavController =
        ref.read(webDavSettingsControllerProvider.notifier);
    final metadataState = ref.watch(metadataSettingsProvider);
    final metadataController = ref.read(metadataSettingsProvider.notifier);
    final List<_MetadataLocaleOption> localeOptions =
        <_MetadataLocaleOption>[
      const _MetadataLocaleOption(label: '跟随系统语言', tag: null),
      const _MetadataLocaleOption(label: '简体中文 (zh-CN)', tag: 'zh-CN'),
      const _MetadataLocaleOption(label: '繁體中文 (zh-TW)', tag: 'zh-TW'),
      const _MetadataLocaleOption(label: '日语 (ja-JP)', tag: 'ja-JP'),
      const _MetadataLocaleOption(label: '英语 (en-US)', tag: 'en-US'),
    ];
    final _MetadataLocaleOption matchedLocale = localeOptions.firstWhere(
      (option) => option.tag == metadataState.manualLocaleTag,
      orElse: () => const _MetadataLocaleOption(label: '', tag: null),
    );
    final String localeLabel = metadataState.manualLocaleTag == null
        ? localeOptions.first.label
        : (matchedLocale.label.isNotEmpty
            ? matchedLocale.label
            : '自定义 (${metadataState.manualLocaleTag})');
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
        appBar: const SysAppBar(title: Text('设置'), needTopOffset: false),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: const Text('通用'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/theme');
                  },
                  leading: const Icon(Icons.palette_rounded),
                  title: const Text('外观设置'),
                  description: const Text('设置应用主题和刷新率'),
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
                    title: const Text('关闭时'),
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
              title: const Text('源'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/plugin');
                  },
                  leading: const Icon(Icons.extension),
                  title: const Text('规则管理'),
                  description: const Text('管理番剧资源规则'),
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
                  title: const Text('Github 镜像'),
                  description: const Text('使用镜像访问规则托管仓库'),
                  initialValue: webDavState.enableGitProxy,
                ),
              ],
            ),
            SettingsSection(
              title: const Text('元数据'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    await metadataController.setBangumiEnabled(
                      value ?? !metadataState.bangumiEnabled,
                    );
                  },
                  title: const Text('启用 Bangumi 元数据'),
                  description: const Text('从 Bangumi 拉取番剧信息'),
                  initialValue: metadataState.bangumiEnabled,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    await metadataController.setTmdbEnabled(
                      value ?? !metadataState.tmdbEnabled,
                    );
                  },
                  title: const Text('启用 TMDb 元数据'),
                  description: const Text('从 TMDb 补充多语言资料'),
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
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('优先语言'),
                  description: const Text('设置元数据同步时使用的语言'),
                  value: MenuAnchor(
                    consumeOutsideTap: true,
                    controller: _metadataLocaleMenuController,
                    builder: (_, __, ___) {
                      return Text(localeLabel);
                    },
                    menuChildren: [
                      for (final _MetadataLocaleOption option in localeOptions)
                        MenuItemButton(
                          requestFocusOnHover: false,
                          onPressed: () async {
                            await metadataController
                                .setManualLocale(option.tag);
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
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
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
              title: const Text('播放器设置'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/player');
                  },
                  leading: const Icon(Icons.display_settings_rounded),
                  title: const Text('播放设置'),
                  description: const Text('设置播放器相关参数'),
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/danmaku');
                  },
                  leading: const Icon(Icons.subtitles_rounded),
                  title: const Text('弹幕设置'),
                  description: const Text('设置弹幕相关参数'),
                ),
              ],
            ),
            SettingsSection(
              title: const Text('WebDAV'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/webdav');
                  },
                  leading: const Icon(Icons.cloud),
                  title: const Text('WebDAV'),
                  description: const Text('设置同步参数'),
                ),
              ],
            ),
            // Conditionally show download section if aria2 is available
            if (Aria2FeatureManager().isAvailable)
              SettingsSection(
                title: const Text('下载'),
                tiles: [
                  SettingsTile.navigation(
                    onPressed: (_) {
                      context.push('/settings/download');
                    },
                    leading: const Icon(Icons.download),
                    title: const Text('下载设置'),
                    description: const Text('配置 aria2 下载参数'),
                  ),
                ],
              ),
            SettingsSection(
              title: const Text('其他'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/about');
                  },
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('关于'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataLocaleOption {
  const _MetadataLocaleOption({required this.label, required this.tag});

  final String label;
  final String? tag;
}
