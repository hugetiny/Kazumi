import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/pages/my/providers.dart';
import 'package:kazumi/pages/setting/setting_controller.dart';
import 'package:kazumi/pages/setting/providers.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/shaders/providers.dart';
import 'package:kazumi/shaders/shaders_controller.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/webdav.dart';
import 'package:logger/logger.dart';

class InitPage extends ConsumerStatefulWidget {
  const InitPage({super.key});

  @override
  ConsumerState<InitPage> createState() => _InitPageState();
}

class _InitPageState extends ConsumerState<InitPage> {
  late final PluginsController pluginsController;
  late final CollectController collectController;
  late final ShadersController shadersController;
  late final MyController myController;
  late final Box setting;

  @override
  void initState() {
    super.initState();
  pluginsController = ref.read(pluginsControllerProvider.notifier);
    collectController = ref.read(collectControllerProvider.notifier);
    shadersController = ref.read(shadersControllerProvider);
    myController = ref.read(myControllerProvider.notifier);
    setting = GStorage.setting;

    _pluginInit();
    _webDavInit();
    _migrateStorage();
    _loadShaders();
    _loadDanmakuShield();
    _update();
  }

  void _syncThemeFromSettings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final useDynamicColor =
          setting.get(SettingBoxKey.useDynamicColor, defaultValue: false);
      ref
          .read(themeNotifierProvider.notifier)
          .setUseDynamicColor(useDynamicColor);
    });
  }

  Future<void> _migrateStorage() async {
    await collectController.migrateCollect();
  }

  Future<void> _loadShaders() async {
    await shadersController.copyShadersToExternalDirectory();
  }

  void _loadDanmakuShield() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      myController.loadShieldList();
    });
  }

  Future<void> _webDavInit() async {
    final webDavEnable =
        await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
    if (!webDavEnable) return;

    final webDav = WebDav();
    KazumiLogger().log(Level.info, '开始从WEBDAV同步记录');
    try {
      await webDav.init();
      await webDav.downloadAndPatchHistory();
      KazumiLogger().log(Level.info, '同步观看记录完成');
    } catch (e) {
      KazumiLogger().log(Level.error, 'WebDav同步失败: $e');
      KazumiDialog.showToast(message: '同步观看记录失败 ${e.toString()}');
    }
  }

  Future<void> _pluginInit() async {
    var statementsText = '';
    try {
      await pluginsController.init();
      statementsText =
          await rootBundle.loadString('assets/statements/statements.txt');
      await _pluginUpdate();
    } catch (_) {}

    if (!mounted) return;

    if (pluginsController.pluginList.isEmpty) {
      await KazumiDialog.show(
        clickMaskDismiss: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('免责声明'),
              scrollable: true,
              content: Text(statementsText),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(
                    '退出',
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.outline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await pluginsController.copyPluginsToExternalDirectory();
                    } catch (_) {}
                    KazumiDialog.dismiss();
                    if (!Platform.isAndroid) {
                      _goHome();
                    } else {
                      await _switchUpdateMirror();
                    }
                  },
                  child: const Text('已阅读并同意'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      _syncThemeFromSettings();
      _goHome();
    }
  }

  Future<void> _switchUpdateMirror() async {
    await KazumiDialog.show(
      clickMaskDismiss: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('更新镜像'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('您希望从哪里获取应用更新？'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Github镜像为大多数情况下的最佳选择。如果您使用F-Droid应用商店, 请选择F-Droid镜像。',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setting.put(SettingBoxKey.autoUpdate, true);
                  KazumiDialog.dismiss();
                  _goHome();
                },
                child: const Text('Github'),
              ),
              TextButton(
                onPressed: () {
                  setting.put(SettingBoxKey.autoUpdate, false);
                  KazumiDialog.dismiss();
                  _goHome();
                },
                child: const Text('F-Droid'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _update() async {
    if (pluginsController.pluginList.isEmpty) {
      _syncThemeFromSettings();
      return;
    }

    final autoUpdate = setting.get(SettingBoxKey.autoUpdate, defaultValue: true);
    if (autoUpdate) {
      await myController.checkUpdate(type: 'auto');
    }
  }

  Future<void> _pluginUpdate() async {
    await pluginsController.queryPluginHTTPList();
    var count = 0;
    for (final plugin in pluginsController.pluginList) {
      if (pluginsController.pluginUpdateStatus(plugin) == 'updatable') {
        count++;
      }
    }
    if (count != 0) {
      KazumiDialog.showToast(message: '检测到 $count 条规则可以更新');
    }
  }

  void _goHome() {
    if (!mounted) return;
    context.go('/tab/popular');
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.shortestSide >= 600 &&
        (MediaQuery.of(context).size.shortestSide /
                MediaQuery.of(context).size.longestSide >=
            9 / 16);

    if (isWideScreen) {
      KazumiLogger().log(Level.info, '当前设备宽屏');
    } else {
      KazumiLogger().log(Level.info, '当前设备非宽屏');
    }
    setting.put(SettingBoxKey.isWideScreen, isWideScreen);
    return const LoadingWidget();
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
