import 'dart:io';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/setting/providers.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/storage.dart';

class PlayerSettingsPage extends ConsumerStatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  ConsumerState<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends ConsumerState<PlayerSettingsPage> {
  final Box setting = GStorage.setting;
  final MenuController menuController = MenuController();

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(playerSettingsProvider.notifier);
    final initialState = PlayerSettingsState(
      defaultPlaySpeed:
          (setting.get(SettingBoxKey.defaultPlaySpeed, defaultValue: 1.0) as num)
              .toDouble(),
      defaultAspectRatioType:
          setting.get(SettingBoxKey.defaultAspectRatioType, defaultValue: 1) as int,
      hAenable: setting.get(SettingBoxKey.hAenable, defaultValue: true) as bool,
      androidEnableOpenSLES:
          setting.get(SettingBoxKey.androidEnableOpenSLES, defaultValue: true) as bool,
      lowMemoryMode:
          setting.get(SettingBoxKey.lowMemoryMode, defaultValue: false) as bool,
      playResume: setting.get(SettingBoxKey.playResume, defaultValue: true) as bool,
      showPlayerError:
          setting.get(SettingBoxKey.showPlayerError, defaultValue: true) as bool,
      privateMode: setting.get(SettingBoxKey.privateMode, defaultValue: false) as bool,
      playerDebugMode:
      setting.get(SettingBoxKey.playerDebugMode, defaultValue: kDebugMode) as bool,
      playerDisableAnimations: setting.get(
        SettingBoxKey.playerDisableAnimations,
        defaultValue: false,
      ) as bool,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      notifier.initialize(initialState);
    });
  }

  void onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
    }
  }

  void updateDefaultPlaySpeed(double speed) {
    setting.put(SettingBoxKey.defaultPlaySpeed, speed);
    ref.read(playerSettingsProvider.notifier).setDefaultPlaySpeed(speed);
  }

  void updateDefaultAspectRatioType(int type) {
    setting.put(SettingBoxKey.defaultAspectRatioType, type);
    ref.read(playerSettingsProvider.notifier).setDefaultAspectRatioType(type);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerSettingsProvider);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('播放设置')),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.hAenable;
                    await setting.put(SettingBoxKey.hAenable, v);
                    ref.read(playerSettingsProvider.notifier).setHAEnable(v);
                  },
                  title: const Text('硬件解码'),
                  initialValue: playerState.hAenable,
                ),
                SettingsTile.navigation(
                  onPressed: (_) async {
                    context.push('/settings/player/decoder');
                  },
                  title: const Text('硬件解码器'),
                  description: const Text('仅在硬件解码启用时生效'),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.lowMemoryMode;
                    await setting.put(SettingBoxKey.lowMemoryMode, v);
                    ref
                        .read(playerSettingsProvider.notifier)
                        .setLowMemoryMode(v);
                  },
                  title: const Text('低内存模式'),
                  description: const Text('禁用高级缓存以减少内存占用'),
                  initialValue: playerState.lowMemoryMode,
                ),
                if (Platform.isAndroid)
                  SettingsTile.switchTile(
                    onToggle: (value) async {
                      final v = value ?? !playerState.androidEnableOpenSLES;
                      await setting.put(SettingBoxKey.androidEnableOpenSLES, v);
                      ref
                          .read(playerSettingsProvider.notifier)
                          .setAndroidEnableOpenSLES(v);
                    },
                    title: const Text('低延迟音频'),
                    description: const Text('启用 OpenSLES 音频输出以降低延时'),
                    initialValue: playerState.androidEnableOpenSLES,
                  ),
                SettingsTile.navigation(
                  onPressed: (_) async {
                    context.push('/settings/player/super');
                  },
                  title: const Text('超分辨率'),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.playResume;
                    await setting.put(SettingBoxKey.playResume, v);
                    ref.read(playerSettingsProvider.notifier).setPlayResume(v);
                  },
                  title: const Text('自动跳转'),
                  description: const Text('跳转到上次播放位置'),
                  initialValue: playerState.playResume,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.playerDisableAnimations;
                    await setting.put(SettingBoxKey.playerDisableAnimations, v);
                    ref
                        .read(playerSettingsProvider.notifier)
                        .setPlayerDisableAnimations(v);
                  },
                  title: const Text('禁用动画'),
                  description: const Text('禁用播放器内的过渡动画'),
                  initialValue: playerState.playerDisableAnimations,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.showPlayerError;
                    await setting.put(SettingBoxKey.showPlayerError, v);
                    ref
                        .read(playerSettingsProvider.notifier)
                        .setShowPlayerError(v);
                  },
                  title: const Text('错误提示'),
                  description: const Text('显示播放器内部错误提示'),
                  initialValue: playerState.showPlayerError,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.playerDebugMode;
                    await setting.put(SettingBoxKey.playerDebugMode, v);
                    ref
                        .read(playerSettingsProvider.notifier)
                        .setPlayerDebugMode(v);
                  },
                  title: const Text('调试模式'),
                  description: const Text('记录播放器内部日志'),
                  initialValue: playerState.playerDebugMode,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final v = value ?? !playerState.privateMode;
                    await setting.put(SettingBoxKey.privateMode, v);
                    ref
                        .read(playerSettingsProvider.notifier)
                        .setPrivateMode(v);
                  },
                  title: const Text('隐身模式'),
                  description: const Text('不保留观看记录'),
                  initialValue: playerState.privateMode,
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: const Text('默认倍速'),
                  description: Slider(
                    value: playerState.defaultPlaySpeed,
                    min: 0.25,
                    max: 3,
                    divisions: 11,
                    label: '${playerState.defaultPlaySpeed}x',
                    onChanged: (value) {
                      updateDefaultPlaySpeed(
                        double.parse(value.toStringAsFixed(2)),
                      );
                    },
                  ),
                ),
                SettingsTile.navigation(
                  onPressed: (_) async {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  },
                  title: const Text('默认视频比例'),
                  value: MenuAnchor(
                    consumeOutsideTap: true,
                    controller: menuController,
                    builder: (_, __, ___) {
                      return Text(
                        aspectRatioTypeMap[playerState.defaultAspectRatioType] ??
                            '自动',
                      );
                    },
                    menuChildren: [
                      for (final entry in aspectRatioTypeMap.entries)
                        MenuItemButton(
                          requestFocusOnHover: false,
                          onPressed: () => updateDefaultAspectRatioType(entry.key),
                          child: Container(
                            height: 48,
                            constraints: const BoxConstraints(minWidth: 112),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: entry.key ==
                                          playerState.defaultAspectRatioType
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
          ],
        ),
      ),
    );
  }
}
