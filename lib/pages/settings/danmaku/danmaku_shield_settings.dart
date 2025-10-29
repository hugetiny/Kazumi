import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/pages/setting/setting_controller.dart';

class DanmakuShieldSettings extends ConsumerStatefulWidget {
  const DanmakuShieldSettings({super.key});

  @override
  ConsumerState<DanmakuShieldSettings> createState() => _DanmakuShieldSettingsState();
}

class _DanmakuShieldSettingsState extends ConsumerState<DanmakuShieldSettings> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure shield list is loaded when entering the screen.
    ref.read(myControllerProvider.notifier).loadShieldList();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shieldState = ref.watch(myControllerProvider);
    final controller = ref.read(myControllerProvider.notifier);

    return Scaffold(
      appBar: const SysAppBar(
        title: Text('弹幕屏蔽'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: '输入关键词或正则表达式',
              suffixIcon: TextButton.icon(
                onPressed: () {
                  controller.addShieldList(textEditingController.text);
                },
                icon: const Icon(Icons.add),
                label: const Text('添加'),
              ),
            ),
            onSubmitted: (_) {
              controller.addShieldList(textEditingController.text);
            },
          ),
          const SizedBox(height: 12),
          const Text('以"/"开头和结尾将视作正则表达式, 如"/\\d+/"表示屏蔽所有数字'),
          const SizedBox(height: 12),
          Text('已添加${shieldState.shieldList.length}个关键词'),
          const SizedBox(height: 12),
          Wrap(
            runSpacing: 12,
            spacing: 12,
            children: shieldState.shieldList
                .map(
                  (item) => Chip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    label: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    deleteButtonTooltipMessage: '',
                    onDeleted: () {
                      controller.removeShieldList(item);
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
