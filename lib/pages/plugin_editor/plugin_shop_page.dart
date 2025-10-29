import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/widget/error_widget.dart';
import 'package:kazumi/modules/plugin/plugin_http_module.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/utils/storage.dart';

class PluginShopPage extends ConsumerStatefulWidget {
  const PluginShopPage({super.key});

  @override
  ConsumerState<PluginShopPage> createState() => _PluginShopPageState();
}

class _PluginShopPageState extends ConsumerState<PluginShopPage> {
  final Box setting = GStorage.setting;
  bool timeout = false;
  bool loading = false;
  late bool enableGitProxy;

  bool sortByName = false;
  late final PluginsController pluginsController;

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
    enableGitProxy =
        setting.get(SettingBoxKey.enableGitProxy, defaultValue: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (pluginsController.pluginHTTPList.isEmpty) {
        _handleRefresh();
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (loading) {
      return;
    }

    setState(() {
      loading = true;
      timeout = false;
    });

    enableGitProxy =
        setting.get(SettingBoxKey.enableGitProxy, defaultValue: false);

    try {
      await pluginsController.queryPluginHTTPList();
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
        timeout = pluginsController.pluginHTTPList.isEmpty;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
        timeout = true;
      });
    }
  }

  void _toggleSort() {
    setState(() {
      sortByName = !sortByName;
    });
  }

  Widget buildPluginHTTPListBody(List<PluginHTTPItem> pluginHTTPList) {
    final sortedList = List<PluginHTTPItem>.from(pluginHTTPList);

    if (sortByName) {
      sortedList.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else {
      sortedList.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
    }

    return ListView.builder(
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        final status = pluginsController.pluginStatus(item);

        return Card(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ListTile(
            title: Row(
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        item.version,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        item.useNativePlayer ? 'native' : 'webview',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.lastUpdate > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '更新时间: ${DateTime.fromMillisecondsSinceEpoch(item.lastUpdate).toString().split('.')[0]}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
            trailing: TextButton(
              onPressed: status == 'installed'
                  ? null
                  : () async {
                      KazumiDialog.showToast(
                        message: status == 'install' ? '导入中' : '更新中',
                      );
                      final res = await pluginsController
                          .tryUpdatePluginByName(item.name);
                      if (res == 0) {
                        KazumiDialog.showToast(
                          message:
                              status == 'install' ? '导入成功' : '更新成功',
                        );
                      } else if (res == 1) {
                        KazumiDialog.showToast(
                          message: 'kazumi版本过低, 此规则不兼容当前版本',
                        );
                      } else if (res == 2) {
                        KazumiDialog.showToast(
                          message: status == 'install'
                              ? '导入规则失败'
                              : '更新规则失败',
                        );
                      }
                    },
              child: Text(
                status == 'install'
                    ? '添加'
                    : status == 'installed'
                        ? '已添加'
                        : '更新',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get timeoutWidget {
    return Center(
      child: GeneralErrorWidget(
        errMsg:
            '啊咧（⊙.⊙） 无法访问远程仓库\n${enableGitProxy ? '镜像已启用' : '镜像已禁用'}',
        actions: [
          GeneralErrorButton(
            onPressed: () {
              if (!mounted) {
                return;
              }
              context.go('/tab/my');
            },
            text: enableGitProxy ? '禁用镜像' : '启用镜像',
          ),
          GeneralErrorButton(
            onPressed: () {
              _handleRefresh();
            },
            text: '刷新',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pluginsState = ref.watch(pluginsControllerProvider);
    final pluginHTTPList = pluginsState.pluginHTTPList;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(
          title: const Text('规则仓库'),
          actions: [
            IconButton(
              onPressed: _toggleSort,
              tooltip: sortByName ? '按名称排序' : '按更新时间排序',
              icon: Icon(
                sortByName ? Icons.sort_by_alpha : Icons.access_time,
              ),
            ),
            IconButton(
              onPressed: _handleRefresh,
              tooltip: '刷新规则列表',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : pluginHTTPList.isEmpty
                ? (timeout ? timeoutWidget : const SizedBox.shrink())
                : buildPluginHTTPListBody(pluginHTTPList),
      ),
    );
  }
}
