import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/widget/error_widget.dart';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/pages/collect/collect_controller.dart';
import 'package:kazumi/pages/collect/providers.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/pages/info/source_search_provider.dart';
import 'package:kazumi/pages/video/providers.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class SourceSheet extends ConsumerStatefulWidget {
  const SourceSheet({
    super.key,
    required this.tabController,
    required this.infoController,
  });

  final TabController tabController;
  final InfoController infoController;

  @override
  ConsumerState<SourceSheet> createState() => _SourceSheetState();
}

class _SourceSheetState extends ConsumerState<SourceSheet> {
  late final VideoPageController videoPageController;
  late final CollectController collectController;
  late String keyword;

  @override
  void initState() {
    super.initState();
    videoPageController = ref.read(videoControllerProvider.notifier);
    collectController = ref.read(collectControllerProvider.notifier);
    keyword = widget.infoController.bangumiItem.nameCn.isEmpty
        ? widget.infoController.bangumiItem.name
        : widget.infoController.bangumiItem.nameCn;
  }

  void _showAliasSearchDialog(
    String pluginName,
    SourceSearchController searchController,
  ) {
    final existingAlias = widget.infoController.bangumiItem.alias;
    if (existingAlias.isEmpty) {
      KazumiDialog.showToast(message: '无可用别名，试试手动检索');
      return;
    }

    final aliasNotifier = ValueNotifier<List<String>>(
      List<String>.from(existingAlias),
    );

    KazumiDialog.show(
      builder: (dialogContext) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 560,
            child: ValueListenableBuilder<List<String>>(
              valueListenable: aliasNotifier,
              builder: (context, aliasList, _) {
                return ListView(
                  shrinkWrap: true,
                  children: aliasList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alias = entry.value;
                    return ListTile(
                      title: Text(alias),
                      trailing: IconButton(
                        onPressed: () {
                          KazumiDialog.show(
                            builder: (confirmContext) {
                              return AlertDialog(
                                title: const Text('删除确认'),
                                content:
                                    const Text('删除后无法恢复，确认要永久删除这个别名吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: KazumiDialog.dismiss,
                                    child: Text(
                                      '取消',
                                      style: TextStyle(
                                        color: Theme.of(confirmContext)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      KazumiDialog.dismiss();
                                      final updated = List<String>.from(
                                        widget.infoController.bangumiItem.alias,
                                      )..removeAt(index);
                                      widget.infoController.bangumiItem.alias =
                                          updated;
                                      aliasNotifier.value = List<String>.from(
                                        updated,
                                      );
                                      collectController.updateLocalCollect(
                                        widget.infoController.bangumiItem,
                                      );
                                      if (updated.isEmpty) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                                    child: const Text('确认'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      onTap: () {
                        KazumiDialog.dismiss();
                        searchController.queryPlugin(
                          pluginName,
                          keywordOverride: alias,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCustomSearchDialog(
    String pluginName,
    SourceSearchController searchController,
  ) {
    KazumiDialog.show(
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('输入别名'),
          content: TextField(
            controller: textController,
            onSubmitted: (value) {
              final alias = textController.text.trim();
              if (alias.isEmpty) {
                return;
              }
              widget.infoController.bangumiItem.alias.add(alias);
              collectController.updateLocalCollect(
                widget.infoController.bangumiItem,
              );
              KazumiDialog.dismiss();
              searchController.queryPlugin(
                pluginName,
                keywordOverride: alias,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: KazumiDialog.dismiss,
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () {
                final alias = textController.text.trim();
                if (alias.isEmpty) {
                  return;
                }
                widget.infoController.bangumiItem.alias.add(alias);
                collectController.updateLocalCollect(
                  widget.infoController.bangumiItem,
                );
                KazumiDialog.dismiss();
                searchController.queryPlugin(
                  pluginName,
                  keywordOverride: alias,
                );
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Color _statusColor(PluginSearchStatus status, ThemeData theme) {
    switch (status) {
      case PluginSearchStatus.success:
        return Colors.green;
      case PluginSearchStatus.error:
        return theme.colorScheme.error;
      case PluginSearchStatus.pending:
        return theme.colorScheme.outline;
    }
  }

  Future<void> _openSearchPage(Plugin plugin) async {
    if (plugin.searchURL.isEmpty) {
      KazumiDialog.showToast(message: '该规则未提供检索链接');
      return;
    }
    final url = plugin.searchURL.replaceFirst('@keyword', keyword);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _handleSearchItemTap(
    BuildContext context,
    Plugin plugin,
    SearchItem searchItem,
  ) async {
    KazumiDialog.showLoading(
      msg: '获取中',
      barrierDismissible: Utils.isDesktop(),
      onDismiss: videoPageController.cancelQueryRoads,
    );

    videoPageController.bangumiItem = widget.infoController.bangumiItem;
    videoPageController.currentPlugin = plugin;
    videoPageController.title = searchItem.name;
    videoPageController.src = searchItem.src;

    try {
      await videoPageController.queryRoads(searchItem.src, plugin.name);
      KazumiDialog.dismiss();
      if (!mounted) return;
      context.push('/video');
    } catch (error) {
      KazumiLogger().log(Level.warning, '获取视频播放列表失败: $error');
      KazumiDialog.dismiss();
      KazumiDialog.showToast(message: '获取视频播放列表失败');
    }
  }

  Widget _buildPluginResultView(
    BuildContext context,
    Plugin plugin,
    PluginSearchStatus status,
    List<SearchItem> results,
    SourceSearchController searchController,
  ) {
    switch (status) {
      case PluginSearchStatus.pending:
        return const Center(child: CircularProgressIndicator());
      case PluginSearchStatus.error:
        return GeneralErrorWidget(
          errMsg: '${plugin.name} 检索失败 重试或左右滑动以切换到其他视频来源',
          actions: [
            GeneralErrorButton(
              onPressed: () {
                searchController.queryPlugin(plugin.name);
              },
              text: '重试',
            ),
          ],
        );
      case PluginSearchStatus.success:
        if (results.isEmpty) {
          return GeneralErrorWidget(
            errMsg: '${plugin.name} 无结果 使用别名或左右滑动以切换到其他视频来源',
            actions: [
              GeneralErrorButton(
                onPressed: () => _showAliasSearchDialog(
                  plugin.name,
                  searchController,
                ),
                text: '别名检索',
              ),
              GeneralErrorButton(
                onPressed: () => _showCustomSearchDialog(
                  plugin.name,
                  searchController,
                ),
                text: '手动检索',
              ),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _handleSearchItemTap(context, plugin, item),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(item.name),
                ),
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pluginState = ref.watch(pluginsControllerProvider);
    final plugins = pluginState.pluginList;
    if (plugins.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plugins.length != widget.tabController.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('插件列表已变更，请关闭面板后重新打开以刷新来源列表'),
        ),
      );
    }

    // Ensure the tab index never exceeds the available plugin list.
    if (widget.tabController.index >= plugins.length) {
      widget.tabController.index = plugins.length - 1;
    }

    final searchState = ref.watch(sourceSearchProvider(keyword));
    final searchController = ref.read(sourceSearchProvider(keyword).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  dividerHeight: 0,
                  controller: widget.tabController,
                  tabs: plugins.map((plugin) {
                    final status =
                        searchState.statuses[plugin.name] ??
                            PluginSearchStatus.pending;
                    return Tab(
                      child: Row(
                        children: [
                          Text(
                            plugin.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                                  theme.textTheme.titleMedium?.fontSize ?? 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusColor(status, theme),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final index = widget.tabController.index;
                  if (index < plugins.length) {
                    await _openSearchPage(plugins[index]);
                  }
                },
                icon: const Icon(Icons.open_in_browser_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: plugins.map((plugin) {
                final status =
                    searchState.statuses[plugin.name] ??
                        PluginSearchStatus.pending;
                final results =
                    searchState.results[plugin.name] ?? const <SearchItem>[];
                return _buildPluginResultView(
                  context,
                  plugin,
                  status,
                  results,
                  searchController,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
