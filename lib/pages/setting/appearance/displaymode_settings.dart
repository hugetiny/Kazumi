import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/utils/storage.dart';

class SetDisplayMode extends StatefulWidget {
  const SetDisplayMode({super.key});

  @override
  State<SetDisplayMode> createState() => _SetDisplayModeState();
}

class _SetDisplayModeState extends State<SetDisplayMode> {
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? active;
  DisplayMode? preferred;
  final Box setting = GStorage.setting;

  final ValueNotifier<int> page = ValueNotifier<int>(0);
  late final PageController controller = PageController()
    ..addListener(() {
      page.value = controller.page!.round();
    });

  @override
  void initState() {
    super.initState();
    init();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      fetchAll();
    });
  }

  Future<void> fetchAll() async {
    preferred = await FlutterDisplayMode.preferred;
    active = await FlutterDisplayMode.active;
    await setting.put(SettingBoxKey.displayMode, preferred.toString());
    setState(() {});
  }

  Future<void> init() async {
    try {
      modes = await FlutterDisplayMode.supported;
    } on PlatformException catch (_) {}
    final DisplayMode res = await getDisplayModeType(modes);

    preferred = modes.toList().firstWhere((el) => el == res);
    FlutterDisplayMode.setPreferredMode(preferred!);
  }

  Future<DisplayMode> getDisplayModeType(List<DisplayMode> modes) async {
    final value = setting.get(SettingBoxKey.displayMode);
    var target = DisplayMode.auto;
    if (value != null) {
      target = modes.firstWhere((e) => e.toString() == value);
    }
    return target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('屏幕帧率设置')),
      body: (modes.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SettingsList(
              maxWidth: 1000,
              sections: [
                SettingsSection(
                  title: const Text('没有生效? 重启应用试试'),
                  tiles: modes
                      .map(
                        (mode) => SettingsTile<DisplayMode>.radioTile(
                          radioValue: mode,
                          groupValue: preferred,
                          onChanged: (DisplayMode? newMode) async {
                            await FlutterDisplayMode.setPreferredMode(newMode!);
                            await Future<dynamic>.delayed(
                              const Duration(milliseconds: 100),
                            );
                            await fetchAll();
                          },
                          title: mode == DisplayMode.auto
                              ? const Text('自动')
                              : Text('${mode == active ? "[系统] " : ""}$mode'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
