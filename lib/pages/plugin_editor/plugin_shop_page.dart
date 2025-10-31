import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/widget/error_widget.dart';
import 'package:kazumi/modules/plugin/plugin_http_module.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';
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

    // Load plugin list on first visit
    if (pluginsController.pluginHTTPList.isEmpty) {
      Future.microtask(() {
        if (mounted) {
          _handleRefresh();
        }
      });
    }
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

  Widget buildPluginHTTPListBody(
      BuildContext context, List<PluginHTTPItem> pluginHTTPList) {
    final pluginTexts = context.t.settings.plugins;
    final shopTexts = pluginTexts.shop;
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
    final bool isInstall = status == 'install';
    final bool isInstalled = status == 'installed';
    final formattedTimestamp =
      DateTime.fromMillisecondsSinceEpoch(item.lastUpdate)
        .toString()
        .split('.')[0];

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
                        item.useNativePlayer
                            ? shopTexts.labels.playerType.native
                            : shopTexts.labels.playerType.webview,
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
                    shopTexts.labels.lastUpdated
                        .replaceFirst('{timestamp}', formattedTimestamp),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
            trailing: TextButton(
              onPressed: isInstalled
                  ? null
                  : () async {
                      final loadingMessage = isInstall
                          ? pluginTexts.loading.importing
                          : pluginTexts.loading.updatingSingle;
                      KazumiDialog.showToast(
                        message: loadingMessage,
                      );
                      final res = await pluginsController
                          .tryUpdatePluginByName(item.name);
                      if (res == 0) {
                        KazumiDialog.showToast(
                          message: isInstall
                              ? pluginTexts.toast.importSuccess
                              : pluginTexts.toast.updateSuccess,
                        );
                      } else if (res == 1) {
                        KazumiDialog.showToast(
                          message: pluginTexts.toast.updateIncompatible,
                        );
                      } else if (res == 2) {
                        KazumiDialog.showToast(
                          message: isInstall
                              ? shopTexts.toast.importFailed
                              : pluginTexts.toast.updateFailed,
                        );
                      }
                    },
              child: Text(
                isInstall
                    ? shopTexts.buttons.install
                    : isInstalled
                        ? shopTexts.buttons.installed
                        : shopTexts.buttons.update,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pluginsState = ref.watch(pluginsControllerProvider);
    final pluginHTTPList = pluginsState.pluginHTTPList;
    final pluginTexts = context.t.settings.plugins;
    final shopTexts = pluginTexts.shop;

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
          title: Text(shopTexts.title),
          actions: [
            IconButton(
              onPressed: _toggleSort,
              tooltip: sortByName
                  ? shopTexts.tooltip.sortByName
                  : shopTexts.tooltip.sortByUpdate,
              icon: Icon(
                sortByName ? Icons.sort_by_alpha : Icons.access_time,
              ),
            ),
            IconButton(
              onPressed: _handleRefresh,
              tooltip: shopTexts.tooltip.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : pluginHTTPList.isEmpty
                ? (timeout
                    ? Center(
                        child: GeneralErrorWidget(
                          errMsg: shopTexts.error.unreachable.replaceFirst(
                            '{status}',
                            enableGitProxy
                                ? shopTexts.error.mirrorEnabled
                                : shopTexts.error.mirrorDisabled,
                          ),
                          actions: [
                            GeneralErrorButton(
                              onPressed: () {
                                if (!mounted) {
                                  return;
                                }
                                context.go('/tab/my');
                              },
                              text: enableGitProxy
                                  ? shopTexts.buttons.toggleMirrorDisable
                                  : shopTexts.buttons.toggleMirrorEnable,
                            ),
                            GeneralErrorButton(
                              onPressed: () {
                                _handleRefresh();
                              },
                              text: shopTexts.buttons.refresh,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink())
                : buildPluginHTTPListBody(context, pluginHTTPList),
      ),
    );
  }
}
