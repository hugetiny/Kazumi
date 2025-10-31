import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';
import 'package:kazumi/utils/storage.dart';

class SuperResolutionSettings extends StatefulWidget {
  const SuperResolutionSettings({super.key});

  @override
  State<SuperResolutionSettings> createState() =>
      _SuperResolutionSettingsState();
}

class _SuperResolutionSettingsState extends State<SuperResolutionSettings> {
  late final Box setting = GStorage.setting;
  late bool promptOnEnable;
  late final ValueNotifier<String> superResolutionType = ValueNotifier<String>(
    setting
        .get(SettingBoxKey.defaultSuperResolutionType, defaultValue: 1)
        .toString(),
  );

  @override
  void initState() {
    super.initState();
    promptOnEnable =
        setting.get(SettingBoxKey.superResolutionWarn, defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final superOptions = t.settings.player.superResolutionOptions;
    return Scaffold(
      appBar: SysAppBar(
        title: Text(t.settings.player.superResolutionTitle),
      ),
      body: SettingsList(
        maxWidth: 1000,
        sections: [
          SettingsSection(
            title: Text(t.settings.player.superResolutionHint),
            tiles: [
              _buildOptionTile('1', superOptions.off.label,
                  superOptions.off.description),
              _buildOptionTile('2', superOptions.efficiency.label,
                  superOptions.efficiency.description),
              _buildOptionTile('3', superOptions.quality.label,
                  superOptions.quality.description),
            ],
          ),
          SettingsSection(
            title:
                Text(t.settings.player.superResolutionDefaultBehavior),
            tiles: [
              SettingsTile.switchTile(
                title: Text(t.settings.player.superResolutionClosePrompt),
                description:
                    Text(t.settings.player.superResolutionClosePromptDesc),
                initialValue: promptOnEnable,
                onToggle: (value) async {
                  promptOnEnable = value ?? false;
                  await setting.put(
                    SettingBoxKey.superResolutionWarn,
                    promptOnEnable,
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  SettingsTile<String> _buildOptionTile(
    String value,
    String title,
    String description,
  ) {
    return SettingsTile<String>.radioTile(
      title: Text(title),
      description: Text(description),
      radioValue: value,
      groupValue: superResolutionType.value,
      onChanged: (String? newValue) {
        if (newValue == null) {
          return;
        }
        setting.put(
          SettingBoxKey.defaultSuperResolutionType,
          int.tryParse(newValue) ?? 1,
        );
        setState(() {
          superResolutionType.value = newValue;
        });
      },
    );
  }
}
