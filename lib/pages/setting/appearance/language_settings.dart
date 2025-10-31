import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/pages/setting/providers.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class LanguageSettings extends ConsumerWidget {
  const LanguageSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final localeState = ref.watch(localeSettingsProvider);
    final localeController = ref.read(localeSettingsProvider.notifier);

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

    return Scaffold(
      appBar: SysAppBar(
        title: Text(t.settings.general.language),
      ),
      body: SettingsList(
        maxWidth: 1000,
        sections: [
          SettingsSection(
            title: Text(t.settings.general.languageDesc),
            tiles: appLocaleOptions
                .map(
                  (option) => SettingsTile<String>.radioTile(
                    title: Text(option.label),
                    radioValue: option.locale?.languageTag ?? 'system',
                    groupValue: localeState.followSystem
                        ? 'system'
                        : localeState.appLocale.languageTag,
                    onChanged: (String? value) async {
                      if (value == null) {
                        return;
                      }
                      if (option.locale == null) {
                        await localeController.useSystemLocale();
                      } else {
                        await localeController.setLocale(option.locale!);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AppLocaleOption {
  const _AppLocaleOption({required this.label, required this.locale});

  final String label;
  final AppLocale? locale;
}
