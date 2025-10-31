import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class PluginViewPage extends ConsumerStatefulWidget {
  const PluginViewPage({super.key});

  @override
  ConsumerState<PluginViewPage> createState() => _PluginViewPageState();
}

class _PluginViewPageState extends ConsumerState<PluginViewPage> {
  late final PluginsController pluginsController;

  // 是否处于多选模式
  bool isMultiSelectMode = false;

  // 已选中的规则名称集合
  final Set<String> selectedNames = {};

  Future<void> _handleUpdate() async {
    final pluginTexts = context.t.settings.plugins;
    KazumiDialog.showLoading(msg: pluginTexts.loading.updating);
    int count = await pluginsController.tryUpdateAllPlugin();
    KazumiDialog.dismiss();
    if (count == 0) {
      KazumiDialog.showToast(message: pluginTexts.toast.allUpToDate);
    } else {
      KazumiDialog.showToast(
        message: pluginTexts.toast.updateCount
            .replaceFirst('{count}', count.toString()),
      );
    }
  }

  void _handleAdd() {
    KazumiDialog.show(builder: (context) {
      final pluginTexts = context.t.settings.plugins;
      return AlertDialog(
        // contentPadding: EdgeInsets.zero, // 设置为零以减小内边距
        content: SingleChildScrollView(
          // 使用可滚动的SingleChildScrollView包装Column
          child: Column(
            mainAxisSize: MainAxisSize.min, // 设置为MainAxisSize.min以减小高度
            children: [
              ListTile(
                title: Text(pluginTexts.actions.newRule),
                onTap: () {
                  KazumiDialog.dismiss();
                  context.push(
                    '/settings/plugin/editor',
                    extra: Plugin.fromTemplate(),
                  );
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(pluginTexts.actions.importFromRepo),
                onTap: () {
                  KazumiDialog.dismiss();
                  context.push('/settings/plugin/shop');
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(pluginTexts.actions.importFromClipboard),
                onTap: () {
                  KazumiDialog.dismiss();
                  _showInputDialog();
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showInputDialog() {
    final TextEditingController textController = TextEditingController();
    KazumiDialog.show(builder: (context) {
      final pluginTexts = context.t.settings.plugins;
      return AlertDialog(
        title: Text(pluginTexts.dialogs.importTitle),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return TextField(
            controller: textController,
          );
        }),
        actions: [
          TextButton(
            onPressed: () => KazumiDialog.dismiss(),
            child: Text(
              pluginTexts.actions.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return TextButton(
              onPressed: () async {
                final String msg = textController.text;
                try {
                  pluginsController.updatePlugin(Plugin.fromJson(
                      json.decode(Utils.kazumiBase64ToJson(msg))));
                  KazumiDialog.showToast(
                      message: pluginTexts.toast.importSuccess);
                } catch (e) {
                  KazumiDialog.dismiss();
                  KazumiDialog.showToast(
                    message: pluginTexts.toast.importFailed
                        .replaceFirst('{error}', e.toString()),
                  );
                }
                KazumiDialog.dismiss();
              },
              child: Text(pluginTexts.actions.import),
            );
          })
        ],
      );
    });
  }

  void onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    pluginsController = ref.read(pluginsControllerProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final pluginsState = ref.watch(pluginsControllerProvider);
    final pluginList = pluginsState.pluginList;
    final pluginTexts = context.t.settings.plugins;
    return PopScope(
      canPop: !isMultiSelectMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (isMultiSelectMode) {
          setState(() {
            isMultiSelectMode = false;
            selectedNames.clear();
          });
          return;
        }
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(
          title: isMultiSelectMode
              ? Text(
                  pluginTexts.multiSelect.selectedCount.replaceFirst(
                    '{count}',
                    selectedNames.length.toString(),
                  ),
                )
              : Text(pluginTexts.title),
          leading: isMultiSelectMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isMultiSelectMode = false;
                      selectedNames.clear();
                    });
                  },
                )
              : null,
          actions: [
            if (isMultiSelectMode) ...[
              IconButton(
                onPressed: selectedNames.isEmpty
                    ? null
                    : () {
                        KazumiDialog.show(
                          builder: (context) => AlertDialog(
                            title: Text(pluginTexts.dialogs.deleteTitle),
                            content: Text(
                              pluginTexts.dialogs.deleteMessage.replaceFirst(
                                '{count}',
                                selectedNames.length.toString(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => KazumiDialog.dismiss(),
                                child: Text(
                                  pluginTexts.actions.cancel,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  pluginsController
                                      .removePlugins(selectedNames);
                                  setState(() {
                                    isMultiSelectMode = false;
                                    selectedNames.clear();
                                  });
                                  KazumiDialog.dismiss();
                                },
                                child: Text(pluginTexts.actions.delete),
                              ),
                            ],
                          ),
                        );
                      },
                icon: const Icon(Icons.delete),
              ),
            ] else ...[
              IconButton(
                onPressed: () {
                  _handleUpdate();
                },
                tooltip: pluginTexts.tooltip.updateAll,
                icon: const Icon(Icons.update),
              ),
              IconButton(
                onPressed: () {
                  _handleAdd();
                },
                tooltip: pluginTexts.tooltip.addRule,
                icon: const Icon(Icons.add),
              )
            ],
          ],
        ),
        body: pluginList.isEmpty
            ? Center(
                child: Text(pluginTexts.empty),
              )
            : Builder(builder: (context) {
                return ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 0,
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      pluginsController.onReorder(oldIndex, newIndex);
                    },
                    itemCount: pluginList.length,
                    itemBuilder: (context, index) {
                      final plugin = pluginList[index];
                      final bool canUpdate =
                          pluginsController.pluginUpdateStatus(plugin) ==
                              'updatable';
                      return Card(
                        key: ValueKey(index),
                        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: ListTile(
                          trailing:
                              pluginCardTrailing(context, index, plugin),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onLongPress: () {
                            if (!isMultiSelectMode) {
                              setState(() {
                                isMultiSelectMode = true;
                                selectedNames.add(plugin.name);
                              });
                            }
                          },
                          onTap: () {
                            if (isMultiSelectMode) {
                              setState(() {
                                if (selectedNames.contains(plugin.name)) {
                                  selectedNames.remove(plugin.name);
                                  if (selectedNames.isEmpty) {
                                    isMultiSelectMode = false;
                                  }
                                } else {
                                  selectedNames.add(plugin.name);
                                }
                              });
                            }
                          },
                          selected: selectedNames.contains(plugin.name),
                          selectedTileColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          title: Text(
                            plugin.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    pluginTexts.labels.version.replaceFirst(
                                      '{version}',
                                      plugin.version,
                                    ),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (canUpdate) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        pluginTexts.labels.statusUpdatable,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (pluginsController.validityTracker
                                      .isSearchValid(plugin.name)) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        pluginTexts.labels.statusSearchValid,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }),
      ),
    );
  }

  Widget pluginCardTrailing(
      BuildContext context, int index, Plugin plugin) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      isMultiSelectMode
          ? Checkbox(
              value: selectedNames.contains(plugin.name),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedNames.add(plugin.name);
                  } else {
                    selectedNames.remove(plugin.name);
                    if (selectedNames.isEmpty) {
                      isMultiSelectMode = false;
                    }
                  }
                });
              },
            )
          : popupMenuButton(context, index, plugin),
      ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle), // 单独的拖拽按钮
      )
    ]);
  }

  Widget popupMenuButton(BuildContext context, int index, Plugin plugin) {
    final pluginTexts = context.t.settings.plugins;
    return MenuAnchor(
      consumeOutsideTap: true,
      builder:
          (BuildContext menuContext, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
      menuChildren: [
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () async {
            var state = pluginsController.pluginUpdateStatus(plugin);
            if (state == "nonexistent") {
              KazumiDialog.showToast(
                  message: pluginTexts.toast.repoMissing);
            } else if (state == "latest") {
              KazumiDialog.showToast(
                  message: pluginTexts.toast.alreadyLatest);
            } else if (state == "updatable") {
              KazumiDialog.showLoading(
                  msg: pluginTexts.loading.updatingSingle);
              int res = await pluginsController.tryUpdatePlugin(plugin);
              KazumiDialog.dismiss();
              if (res == 0) {
                KazumiDialog.showToast(
                    message: pluginTexts.toast.updateSuccess);
              } else if (res == 1) {
                KazumiDialog.showToast(
                    message: pluginTexts.toast.updateIncompatible);
              } else if (res == 2) {
                KazumiDialog.showToast(
                    message: pluginTexts.toast.updateFailed);
              }
            }
          },
          child: Container(
            height: 48,
            constraints: BoxConstraints(minWidth: 112),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.update_rounded),
                  SizedBox(width: 8),
                  Text(pluginTexts.actions.update),
                ],
              ),
            ),
          ),
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () {
            context.push('/settings/plugin/editor', extra: plugin);
          },
          child: Container(
            height: 48,
            constraints: BoxConstraints(minWidth: 112),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text(pluginTexts.actions.edit),
                ],
              ),
            ),
          ),
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () {
            KazumiDialog.show(builder: (context) {
              return AlertDialog(
                title: Text(pluginTexts.dialogs.shareTitle),
                content: SelectableText(
                  Utils.jsonToKazumiBase64(json
                      .encode(plugin.toJson())),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => KazumiDialog.dismiss(),
                    child: Text(
                      pluginTexts.actions.cancel,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: Utils.jsonToKazumiBase64(
                          json.encode(
                            plugin.toJson(),
                          ),
                        ),
                      ));
                      KazumiDialog.dismiss();
                      KazumiDialog.showToast(
                          message: pluginTexts.toast.copySuccess);
                    },
                    child: Text(pluginTexts.actions.copyToClipboard),
                  ),
                ],
              );
            });
          },
          child: Container(
            height: 48,
            constraints: BoxConstraints(minWidth: 112),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text(pluginTexts.actions.share),
                ],
              ),
            ),
          ),
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          onPressed: () async {
            setState(() {
              pluginsController.removePlugin(plugin);
            });
          },
          child: Container(
            height: 48,
            constraints: BoxConstraints(minWidth: 112),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text(pluginTexts.actions.delete),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
