import 'package:kazumi/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class DanmakuSettingsPage extends StatefulWidget {
  const DanmakuSettingsPage({super.key});

  @override
  State<DanmakuSettingsPage> createState() => _DanmakuSettingsPageState();
}

class _DanmakuSettingsPageState extends State<DanmakuSettingsPage> {
  Box setting = GStorage.setting;
  late dynamic defaultDanmakuArea;
  late dynamic defaultDanmakuOpacity;
  late dynamic defaultDanmakuFontSize;
  late int defaultDanmakuFontWeight;
  late bool danmakuEnabledByDefault;
  late bool danmakuBorder;
  late bool danmakuTop;
  late bool danmakuBottom;
  late bool danmakuScroll;
  late bool danmakuColor;
  late bool danmakuMassive;
  late bool danmakuBiliBiliSource;
  late bool danmakuGamerSource;
  late bool danmakuDanDanSource;
  late String danDanAppIdOverride;
  late String danDanApiKeyOverride;

  @override
  void initState() {
    super.initState();
    defaultDanmakuArea =
        setting.get(SettingBoxKey.danmakuArea, defaultValue: 1.0);
    defaultDanmakuOpacity =
        setting.get(SettingBoxKey.danmakuOpacity, defaultValue: 1.0);
    defaultDanmakuFontSize = setting.get(SettingBoxKey.danmakuFontSize,
        defaultValue: (Utils.isCompact()) ? 16.0 : 25.0);
    defaultDanmakuFontWeight =
        setting.get(SettingBoxKey.danmakuFontWeight, defaultValue: 4);
    danmakuEnabledByDefault =
        setting.get(SettingBoxKey.danmakuEnabledByDefault, defaultValue: false);
    danmakuBorder =
        setting.get(SettingBoxKey.danmakuBorder, defaultValue: true);
    danmakuTop = setting.get(SettingBoxKey.danmakuTop, defaultValue: true);
    danmakuBottom =
        setting.get(SettingBoxKey.danmakuBottom, defaultValue: false);
    danmakuScroll =
        setting.get(SettingBoxKey.danmakuScroll, defaultValue: true);
    danmakuColor = setting.get(SettingBoxKey.danmakuColor, defaultValue: true);
    danmakuMassive =
        setting.get(SettingBoxKey.danmakuMassive, defaultValue: false);
    danmakuBiliBiliSource =
        setting.get(SettingBoxKey.danmakuBiliBiliSource, defaultValue: true);
    danmakuGamerSource =
        setting.get(SettingBoxKey.danmakuGamerSource, defaultValue: true);
    danmakuDanDanSource =
        setting.get(SettingBoxKey.danmakuDanDanSource, defaultValue: true);
    danDanAppIdOverride =
        (setting.get(SettingBoxKey.danDanAppId, defaultValue: '') as String?)
                ?.trim() ??
            '';
    danDanApiKeyOverride =
        (setting.get(SettingBoxKey.danDanApiKey, defaultValue: '') as String?)
                ?.trim() ??
            '';
  }

  void onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
  }

  void updateDanmakuArea(double i) async {
    await setting.put(SettingBoxKey.danmakuArea, i);
    setState(() {
      defaultDanmakuArea = i;
    });
  }

  void updateDanmakuOpacity(double i) async {
    await setting.put(SettingBoxKey.danmakuOpacity, i);
    setState(() {
      defaultDanmakuOpacity = i;
    });
  }

  void updateDanmakuFontSize(double i) async {
    await setting.put(SettingBoxKey.danmakuFontSize, i);
    setState(() {
      defaultDanmakuFontSize = i;
    });
  }

  void updateDanmakuFontWeight(int i) async {
    await setting.put(SettingBoxKey.danmakuFontWeight, i);
    setState(() {
      defaultDanmakuFontWeight = i;
    });
  }

  String _maskSecret(String secret) {
    if (secret.isEmpty) {
      return context.t.settings.player.danmakuCredentialNotConfigured;
    }
    if (secret.length <= 4) {
      return '*' * secret.length;
    }
    return '${secret.substring(0, 2)}****${secret.substring(secret.length - 2)}';
  }

  String get _credentialModeLabel {
    final playerTexts = context.t.settings.player;
    return danDanAppIdOverride.isEmpty && danDanApiKeyOverride.isEmpty
        ? playerTexts.danmakuCredentialModeBuiltIn
        : playerTexts.danmakuCredentialModeCustom;
  }

  Future<void> _showDanDanCredentialDialog() async {
    final TextEditingController appIdController =
        TextEditingController(text: danDanAppIdOverride);
    final TextEditingController apiKeyController =
        TextEditingController(text: danDanApiKeyOverride);

    Future<void> save(String appId, String apiKey) async {
      await setting.put(SettingBoxKey.danDanAppId, appId);
      await setting.put(SettingBoxKey.danDanApiKey, apiKey);
      if (!mounted) return;
      setState(() {
        danDanAppIdOverride = appId;
        danDanApiKeyOverride = apiKey;
      });
    }

    final playerTexts = context.t.settings.player;
    final appTexts = context.t.app;
    final toastTexts = playerTexts.toast;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(playerTexts.danmakuDanDanCredentials),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: appIdController,
                decoration: InputDecoration(
                  labelText: 'AppId',
                  hintText: playerTexts.danmakuCredentialHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: playerTexts.danmakuCredentialHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(appTexts.cancel),
            ),
            TextButton(
              onPressed: () async {
                final NavigatorState navigator = Navigator.of(dialogContext);
                await save('', '');
                if (!mounted) return;
                navigator.pop();
                KazumiDialog.showToast(
                  message: toastTexts.danmakuCredentialsRestored,
                );
              },
              child: Text(playerTexts.restoreDefault),
            ),
            FilledButton(
              onPressed: () async {
                final String appId = appIdController.text.trim();
                final String apiKey = apiKeyController.text.trim();
                final NavigatorState navigator = Navigator.of(dialogContext);
                await save(appId, apiKey);
                if (!mounted) return;
                navigator.pop();
                KazumiDialog.showToast(
                  message: toastTexts.danmakuCredentialsUpdated,
                );
              },
              child: Text(playerTexts.save),
            ),
          ],
        );
      },
    ).whenComplete(() {
      appIdController.dispose();
      apiKeyController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final translations = context.t;
    final playerTexts = translations.settings.player;
    final sourcesTexts = playerTexts.danmakuSources;
    final String effectiveDanDanAppId = GStorage.readDanDanAppId();
    final String effectiveDanDanApiKey = GStorage.readDanDanApiKey();
    final String maskedApiKey = _maskSecret(effectiveDanDanApiKey);
    final String displayAppId = effectiveDanDanAppId.isEmpty
        ? playerTexts.danmakuCredentialNotConfigured
        : effectiveDanDanAppId;
    final String credentialSummary = playerTexts.danmakuCredentialsSummary
        .replaceFirst('{appId}', displayAppId)
        .replaceFirst('{apiKey}', maskedApiKey);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(title: Text(playerTexts.danmakuSettings)),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: Text(playerTexts.danmaku),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuEnabledByDefault = value ?? !danmakuEnabledByDefault;
                    await setting.put(SettingBoxKey.danmakuEnabledByDefault,
                        danmakuEnabledByDefault);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuDefaultOn),
                  description: Text(playerTexts.danmakuDefaultOnDesc),
                  initialValue: danmakuEnabledByDefault,
                ),
              ],
            ),
            SettingsSection(
              title: Text(playerTexts.danmakuSource),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuBiliBiliSource = value ?? !danmakuBiliBiliSource;
                    await setting.put(SettingBoxKey.danmakuBiliBiliSource,
                        danmakuBiliBiliSource);
                    setState(() {});
                  },
                  title: Text(sourcesTexts.bilibili),
                  initialValue: danmakuBiliBiliSource,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuGamerSource = value ?? !danmakuGamerSource;
                    await setting.put(
                        SettingBoxKey.danmakuGamerSource, danmakuGamerSource);
                    setState(() {});
                  },
                  title: Text(sourcesTexts.gamer),
                  initialValue: danmakuGamerSource,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuDanDanSource = value ?? !danmakuDanDanSource;
                    await setting.put(
                        SettingBoxKey.danmakuDanDanSource, danmakuDanDanSource);
                    setState(() {});
                  },
                  title: Text(sourcesTexts.dandan),
                  initialValue: danmakuDanDanSource,
                ),
              ],
            ),
            SettingsSection(
              title: Text(playerTexts.danmakuCredentials),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) async {
                    await _showDanDanCredentialDialog();
                  },
                  title: Text(playerTexts.danmakuDanDanCredentials),
                  description: Text(credentialSummary),
                  value: Text(_credentialModeLabel),
                ),
              ],
            ),
            SettingsSection(
              title: Text(playerTexts.danmakuShield),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    context.push('/settings/danmaku/shield');
                  },
                  title: Text(playerTexts.danmakuKeywordShield),
                ),
              ],
            ),
            SettingsSection(
              title: Text(playerTexts.danmakuDisplay),
              tiles: [
                SettingsTile(
                  title: Text(playerTexts.danmakuArea),
                  description: Slider(
                    value: defaultDanmakuArea,
                    min: 0,
                    max: 1,
                    divisions: 4,
                    label: '${(defaultDanmakuArea * 100).round()}%',
                    onChanged: (value) {
                      updateDanmakuArea(value);
                    },
                  ),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuTop = value ?? !danmakuTop;
                    await setting.put(SettingBoxKey.danmakuTop, danmakuTop);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuTopDisplay),
                  initialValue: danmakuTop,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuBottom = value ?? !danmakuBottom;
                    await setting.put(
                        SettingBoxKey.danmakuBottom, danmakuBottom);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuBottomDisplay),
                  initialValue: danmakuBottom,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuScroll = value ?? !danmakuScroll;
                    await setting.put(
                        SettingBoxKey.danmakuScroll, danmakuScroll);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuScrollDisplay),
                  initialValue: danmakuScroll,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuMassive = value ?? !danmakuMassive;
                    await setting.put(
                        SettingBoxKey.danmakuMassive, danmakuMassive);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuMassiveDisplay),
                  description: Text(playerTexts.danmakuMassiveDescription),
                  initialValue: danmakuMassive,
                ),
              ],
            ),
            SettingsSection(
              title: Text(playerTexts.danmakuStyle),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuBorder = value ?? !danmakuBorder;
                    await setting.put(
                        SettingBoxKey.danmakuBorder, danmakuBorder);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuOutline),
                  initialValue: danmakuBorder,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuColor = value ?? !danmakuColor;
                    await setting.put(SettingBoxKey.danmakuColor, danmakuColor);
                    setState(() {});
                  },
                  title: Text(playerTexts.danmakuColor),
                  initialValue: danmakuColor,
                ),
                SettingsTile(
                  title: Text(playerTexts.danmakuFontSize),
                  description: Slider(
                    value: defaultDanmakuFontSize,
                    min: 10,
                    max: Utils.isCompact() ? 32 : 48,
                    label: '${defaultDanmakuFontSize.floorToDouble()}',
                    onChanged: (value) {
                      updateDanmakuFontSize(value.floorToDouble());
                    },
                  ),
                ),
                SettingsTile(
                  title: Text(playerTexts.danmakuFontWeight),
                  description: Slider(
                    value: defaultDanmakuFontWeight.toDouble(),
                    min: 1,
                    max: 9,
                    divisions: 8,
                    label: '$defaultDanmakuFontWeight',
                    onChanged: (value) {
                      updateDanmakuFontWeight(value.toInt());
                    },
                  ),
                ),
                SettingsTile(
                  title: Text(playerTexts.danmakuOpacity),
                  description: Slider(
                    value: defaultDanmakuOpacity,
                    min: 0.1,
                    max: 1,
                    label: '${(defaultDanmakuOpacity * 100).round()}%',
                    onChanged: (value) {
                      updateDanmakuOpacity(
                          double.parse(value.toStringAsFixed(2)));
                    },
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
