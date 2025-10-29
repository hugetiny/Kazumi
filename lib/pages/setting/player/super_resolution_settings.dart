import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
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
    return Scaffold(
      appBar: const SysAppBar(
        title: Text('超分辨率'),
      ),
      body: SettingsList(
        maxWidth: 1000,
        sections: [
          SettingsSection(
            title: const Text(
              '超分辨率需要启用硬件解码，若启用硬件解码后仍然不生效，尝试将硬件解码器切换为 auto-copy',
            ),
            tiles: [
              _buildOptionTile('1', 'OFF', '默认禁用超分辨率'),
              _buildOptionTile('2', 'Efficiency', '基于 Anime4K，效率优先'),
              _buildOptionTile('3', 'Quality', '基于 Anime4K，质量优先'),
            ],
          ),
          SettingsSection(
            title: const Text('默认行为'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('关闭提示'),
                description: const Text('关闭每次启用超分辨率时的提示'),
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
