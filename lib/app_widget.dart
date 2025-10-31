import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:logger/logger.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/router.dart';
import 'package:kazumi/pages/setting/providers.dart';
import 'package:kazumi/utils/tray_localization.dart';

class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({super.key});

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends ConsumerState<AppWidget>
    with TrayListener, WidgetsBindingObserver, WindowListener {
  Box setting = GStorage.setting;

  final TrayManager trayManager = TrayManager.instance;
  bool showingExitDialog = false;
  ProviderSubscription<LocaleSettingsState>? _localeSubscription;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
    setPreventClose();
    WidgetsBinding.instance.addObserver(this);
    _localeSubscription = ref.listenManual<LocaleSettingsState>(
      localeSettingsProvider,
      (_, localeState) {
        // Sync global slang locale when provider changes
        if (localeState.followSystem) {
          LocaleSettings.useDeviceLocale();
        } else {
          LocaleSettings.setLocale(localeState.appLocale);
        }
        if (Utils.isDesktop()) {
          _handleTray();
        }
      },
    );

    // Initialize locale from provider on startup
    final initialLocaleState = ref.read(localeSettingsProvider);
    if (initialLocaleState.followSystem) {
      LocaleSettings.useDeviceLocale();
    } else {
      LocaleSettings.setLocale(initialLocaleState.appLocale);
    }

    if (Utils.isDesktop()) {
      _handleTray();
    }
  }

  void setPreventClose() async {
    if (Utils.isDesktop()) {
      await windowManager.setPreventClose(true);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _localeSubscription?.close();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
      case 'exit':
        exit(0);
    }
  }

  /// 处理窗口关闭事件，
  /// 需要使用 `windowManager.close()` 来触发，`exit(0)` 会直接退出程序
  @override
  void onWindowClose() {
    final setting = GStorage.setting;
    final exitBehavior =
        setting.get(SettingBoxKey.exitBehavior, defaultValue: 2);

    switch (exitBehavior) {
      case 0:
        exit(0);
      case 1:
        KazumiDialog.dismiss();
        windowManager.hide();
        break;
      default:
        if (showingExitDialog) return;
        showingExitDialog = true;
        KazumiDialog.show(onDismiss: () {
          showingExitDialog = false;
        }, builder: (context) {
          final t = context.t;
          bool saveExitBehavior = false; // 下次不再询问？

          return AlertDialog(
            title: Text(t.exitDialog.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.exitDialog.message),
                const SizedBox(height: 24),
                StatefulBuilder(builder: (context, setState) {
                  onChanged(value) {
                    saveExitBehavior = value ?? false;
                    setState(() {});
                  }

                  return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Checkbox(value: saveExitBehavior, onChanged: onChanged),
                      Text(t.exitDialog.dontAskAgain),
                    ],
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    if (saveExitBehavior) {
                      await setting.put(SettingBoxKey.exitBehavior, 0);
                    }
                    exit(0);
                  },
                  child: Text(t.exitDialog.exit)),
              TextButton(
                  onPressed: () async {
                    if (saveExitBehavior) {
                      await setting.put(SettingBoxKey.exitBehavior, 1);
                    }
                    KazumiDialog.dismiss();
                    windowManager.hide();
                  },
                  child: Text(t.exitDialog.minimize)),
              TextButton(
                  onPressed: KazumiDialog.dismiss,
                  child: Text(t.exitDialog.cancel)),
            ],
          );
        });
    }
  }

  /// 处理前后台变更
  /// windows/linux 在程序后台或失去焦点时只会触发 inactive 不会触发 paused
  /// android/ios/macos 在程序后台时会先触发 inactive 再触发 paused, 回到前台时会先触发 inactive 再触发 resumed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      debugPrint("应用进入后台");
      // bool webDavEnable =
      //     await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
      // bool webDavEnableHistory = await setting
      //     .get(SettingBoxKey.webDavEnableHistory, defaultValue: false);
      // if (webDavEnable && webDavEnableHistory) {
      //   var webDav = WebDav();
      //   webDav.updateHistory();
      // }
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("应用回到前台");
      // bool webDavEnable =
      //     await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
      // bool webDavEnableHistory = await setting
      //     .get(SettingBoxKey.webDavEnableHistory, defaultValue: false);
      // if (webDavEnable && webDavEnableHistory) {
      //   try {
      //     var webDav = WebDav();
      //     webDav.downloadAndPatchHistory();
      //   } catch (e) {
      //     KazumiLogger().log(Level.error, '同步观看记录失败 ${e.toString()}');
      //   }
      // }
    } else if (state == AppLifecycleState.inactive) {
      debugPrint("应用处于非活动状态");
      // if (Platform.isWindows || Platform.isLinux) {
      //   bool webDavEnable =
      //       await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
      //   bool webDavEnableHistory = await setting
      //       .get(SettingBoxKey.webDavEnableHistory, defaultValue: false);
      //   if (webDavEnable && webDavEnableHistory) {
      //     var webDav = WebDav();
      //     webDav.updateHistory();
      //   }
      // }
    }
  }

  Future<void> _handleTray() async {
    final TrayLabels labels = KazumiTrayLabels.fromRef(ref);
    if (Platform.isWindows) {
      await trayManager.setIcon('assets/images/logo/logo_lanczos.ico');
    } else if (Platform.environment.containsKey('FLATPAK_ID') ||
        Platform.environment.containsKey('SNAP')) {
      await trayManager.setIcon('io.github.Predidit.Kazumi');
    } else {
      await trayManager.setIcon('assets/images/logo/logo_rounded.png');
    }

    if (!Platform.isLinux) {
      await trayManager.setToolTip(labels.tooltip);
    }

    Menu trayMenu = Menu(items: [
      MenuItem(key: 'show_window', label: labels.showWindow),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: labels.exit)
    ]);
    await trayManager.setContextMenu(trayMenu);
  }

  ThemeData _buildLightTheme(ColorScheme? dynamicScheme, Color seedColor) {
    if (dynamicScheme != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: dynamicScheme,
        brightness: Brightness.light,
        progressIndicatorTheme: progressIndicatorTheme2024,
        sliderTheme: sliderTheme2024,
        pageTransitionsTheme: pageTransitionsTheme2024,
      );
    }
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: seedColor,
      progressIndicatorTheme: progressIndicatorTheme2024,
      sliderTheme: sliderTheme2024,
      pageTransitionsTheme: pageTransitionsTheme2024,
    );
  }

  ThemeData _buildDarkTheme(
    ColorScheme? dynamicScheme,
    Color seedColor,
    bool oledEnhance,
  ) {
    ThemeData base;
    if (dynamicScheme != null) {
      base = ThemeData(
        useMaterial3: true,
        colorScheme: dynamicScheme,
        brightness: Brightness.dark,
        progressIndicatorTheme: progressIndicatorTheme2024,
        sliderTheme: sliderTheme2024,
        pageTransitionsTheme: pageTransitionsTheme2024,
      );
    } else {
      base = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: seedColor,
        progressIndicatorTheme: progressIndicatorTheme2024,
        sliderTheme: sliderTheme2024,
        pageTransitionsTheme: pageTransitionsTheme2024,
      );
    }
    return oledEnhance ? Utils.oledDarkTheme(base) : base;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);
    final Color seedColor = themeState.seedColor;
    final bool useDynamicColor = themeState.useDynamicColor;
    final bool oledEnhance = themeState.oledEnhance;

    // Theme initialization is performed in initState via a
    // post-frame callback to avoid modifying providers during build.

    final ThemeData fallbackLightTheme = _buildLightTheme(null, seedColor);
    final ThemeData fallbackDarkTheme =
        _buildDarkTheme(null, seedColor, oledEnhance);

    final Widget app = TranslationProvider(
      child: DynamicColorBuilder(
        builder: (dynamicLight, dynamicDark) {
          final bool canUseDynamic =
              useDynamicColor && dynamicLight != null && dynamicDark != null;

          final ThemeData lightTheme = canUseDynamic
              ? _buildLightTheme(dynamicLight, seedColor)
              : fallbackLightTheme;
          final ThemeData darkTheme = canUseDynamic
              ? _buildDarkTheme(dynamicDark, seedColor, oledEnhance)
              : fallbackDarkTheme;

          return MaterialApp.router(
            title: LocaleSettings.currentLocale.translations.app.title,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: AppLocaleUtils.supportedLocales,
            locale: LocaleSettings.currentLocale.flutterLocale,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: router,
          );
        },
      ),
    );

    // 强制设置高帧率
    if (Platform.isAndroid) {
      try {
        late List modes;
        FlutterDisplayMode.supported.then((value) {
          modes = value;
          var storageDisplay = setting.get(SettingBoxKey.displayMode);
          DisplayMode f = DisplayMode.auto;
          if (storageDisplay != null) {
            f = modes.firstWhere((e) => e.toString() == storageDisplay);
          }
          DisplayMode preferred = modes.toList().firstWhere((el) => el == f);
          FlutterDisplayMode.setPreferredMode(preferred);
        });
      } catch (e) {
        KazumiLogger().log(Level.error, '高帧率设置失败 ${e.toString()}');
      }
    }

    return app;
  }
}
