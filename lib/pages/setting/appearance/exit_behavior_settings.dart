import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class ExitBehaviorSettings extends StatefulWidget {
  const ExitBehaviorSettings({super.key});

  @override
  State<ExitBehaviorSettings> createState() => _ExitBehaviorSettingsState();
}

class _ExitBehaviorSettingsState extends State<ExitBehaviorSettings> {
  late final Box setting = GStorage.setting;
  late int exitBehavior;

  @override
  void initState() {
    super.initState();
    exitBehavior =
        setting.get(SettingBoxKey.exitBehavior, defaultValue: 2) as int;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    final List<String> exitBehaviorTitles = [
      t.settings.general.exitApp,
      t.settings.general.minimizeToTray,
      t.settings.general.askEveryTime,
    ];

    return Scaffold(
      appBar: SysAppBar(
        title: Text(t.settings.general.exitBehavior),
      ),
      body: SettingsList(
        maxWidth: 1000,
        sections: [
          SettingsSection(
            tiles: List.generate(
              exitBehaviorTitles.length,
              (index) => SettingsTile<int>.radioTile(
                title: Text(exitBehaviorTitles[index]),
                radioValue: index,
                groupValue: exitBehavior,
                onChanged: (int? value) async {
                  if (value == null) {
                    return;
                  }
                  await setting.put(SettingBoxKey.exitBehavior, value);
                  setState(() {
                    exitBehavior = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
