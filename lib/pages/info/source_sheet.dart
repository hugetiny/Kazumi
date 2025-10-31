import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/pages/my/providers.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/pages/info/source_search_provider.dart';
import 'package:kazumi/pages/video/providers.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';
import 'package:logger/logger.dart';

enum SourceSortOption { original, nameAsc, nameDesc }

class SourceSheet extends ConsumerStatefulWidget {
  const SourceSheet({
    super.key,
    required this.infoController,
  });

  final InfoController infoController;

  @override
  ConsumerState<SourceSheet> createState() => _SourceSheetState();
}

class _SourceSheetState extends ConsumerState<SourceSheet> {
  late final VideoPageController videoPageController;
  late final CollectController collectController;
  late final String _originalKeyword;
  SourceSortOption _sortOption = SourceSortOption.original;

  @override
  void initState() {
    super.initState();
    videoPageController = ref.read(videoControllerProvider.notifier);
    collectController = ref.read(collectControllerProvider.notifier);
    _originalKeyword = widget.infoController.bangumiItem.nameCn.isEmpty
        ? widget.infoController.bangumiItem.name
        : widget.infoController.bangumiItem.nameCn;
  }

  bool get _hasAlias => widget.infoController.bangumiItem.alias.isNotEmpty;

  void _showAliasSearchDialog(SourceSearchController searchController) {
    final sheetTexts = context.t.library.info.sourceSheet;
    final aliasTexts = sheetTexts.alias;
    final existingAlias = widget.infoController.bangumiItem.alias;
    if (existingAlias.isEmpty) {
      KazumiDialog.showToast(message: sheetTexts.toast.aliasEmpty);
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
                        tooltip: aliasTexts.deleteTooltip,
                        onPressed: () {
                          KazumiDialog.show(
                            builder: (confirmContext) {
                              final confirmTexts =
                                  confirmContext.t.library.info.sourceSheet;
                              final confirmAlias = confirmTexts.alias;
                              return AlertDialog(
                                title: Text(confirmAlias.deleteTitle),
                                content: Text(confirmAlias.deleteMessage),
                                actions: [
                                  TextButton(
                                    onPressed: KazumiDialog.dismiss,
                                    child: Text(
                                      confirmContext.t.app.cancel,
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
                                      )
                                        ..removeAt(index);
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
                                    child: Text(confirmContext.t.app.confirm),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                      onTap: () {
                        KazumiDialog.dismiss();
                        searchController.searchWithKeyword(alias);
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

  String _sortOptionLabel(SourceSortOption option) {
    final options = context.t.library.info.sourceSheet.sort.options;
    switch (option) {
      case SourceSortOption.original:
        return options.original;
      case SourceSortOption.nameAsc:
        return options.nameAsc;
      case SourceSortOption.nameDesc:
        return options.nameDesc;
    }
  }

  List<_SourceEntry> _sortedEntries(List<_SourceEntry> entries) {
    switch (_sortOption) {
      case SourceSortOption.original:
        return entries;
      case SourceSortOption.nameAsc:
        return [...entries]
          ..sort((a, b) => a.item.name.compareTo(b.item.name));
      case SourceSortOption.nameDesc:
        return [...entries]
          ..sort((a, b) => b.item.name.compareTo(a.item.name));
    }
  }

  String _shortenEndpoint(String src) {
    if (src.isEmpty) {
      return src;
    }
    if (src.startsWith('http')) {
      try {
        final uri = Uri.parse(src);
        final buffer = StringBuffer(uri.host);
        if (uri.pathSegments.isNotEmpty) {
          buffer.write('/${uri.pathSegments.first}');
        }
        return buffer.toString();
      } catch (_) {
        return src;
      }
    }
    return src.length > 48 ? '${src.substring(0, 47)}…' : src;
  }

  Future<void> _handleSearchItemTap(
    BuildContext context,
    Plugin plugin,
    SearchItem searchItem,
  ) async {
    final sheetTexts = context.t.library.info.sourceSheet;
    KazumiDialog.showLoading(
      msg: context.t.app.loading,
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
      KazumiDialog.showToast(message: sheetTexts.toast.loadFailed);
    }
  }

  Widget _buildSourceCard(
    BuildContext context,
    Plugin plugin,
    SearchItem item,
  ) {
    final sheetTexts = context.t.library.info.sourceSheet;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleSearchItemTap(context, plugin, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sheetTexts.card.title
                    .replaceFirst('{plugin}', plugin.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                _shortenEndpoint(item.src),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        _handleSearchItemTap(context, plugin, item),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(sheetTexts.card.play),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<SourceSortOption> _buildSortMenu() {
    final sortTexts = context.t.library.info.sourceSheet.sort;
    return PopupMenuButton<SourceSortOption>(
      tooltip: sortTexts.tooltip
          .replaceFirst('{label}', _sortOptionLabel(_sortOption)),
      icon: const Icon(Icons.sort_rounded),
      onSelected: (option) {
        setState(() {
          _sortOption = option;
        });
      },
      itemBuilder: (context) {
        return SourceSortOption.values.map((option) {
          final selected = option == _sortOption;
          return PopupMenuItem<SourceSortOption>(
            value: option,
            child: Row(
              children: [
                if (selected)
                  const Icon(Icons.check_rounded, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 12),
                Text(_sortOptionLabel(option)),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  ({
    List<_SourceEntry> entries,
    List<Plugin> pending,
    List<Plugin> errors,
    List<Plugin> empty,
  }) _aggregateResults(
    List<Plugin> plugins,
    SourceSearchState searchState,
  ) {
    final entries = <_SourceEntry>[];
    final pending = <Plugin>[];
    final errors = <Plugin>[];
    final empty = <Plugin>[];

    for (final plugin in plugins) {
      final status =
          searchState.statuses[plugin.name] ?? PluginSearchStatus.pending;
      final results =
          searchState.results[plugin.name] ?? const <SearchItem>[];
      switch (status) {
        case PluginSearchStatus.pending:
          pending.add(plugin);
          break;
        case PluginSearchStatus.error:
          errors.add(plugin);
          break;
        case PluginSearchStatus.success:
          if (results.isEmpty) {
            empty.add(plugin);
          } else {
            for (final item in results) {
              entries.add(_SourceEntry(plugin, item));
            }
          }
          break;
      }
    }

    return (
      entries: entries,
      pending: pending,
      errors: errors,
      empty: empty,
    );
  }

  List<Widget> _buildStatusCards({
    required List<Plugin> pending,
    required List<Plugin> errors,
    required List<Plugin> empty,
    required SourceSearchController controller,
  }) {
    final sheetTexts = context.t.library.info.sourceSheet;
    final statusTexts = sheetTexts.status;
    final actions = sheetTexts.actions;
    final widgets = <Widget>[];

    for (final plugin in pending) {
      widgets.add(
        Card(
          elevation: 0,
          child: ListTile(
            leading: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            title: Text(
              statusTexts.searching.replaceFirst('{plugin}', plugin.name),
            ),
            dense: true,
          ),
        ),
      );
    }

    for (final plugin in errors) {
      widgets.add(
        Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              statusTexts.failed.replaceFirst('{plugin}', plugin.name),
            ),
            dense: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => controller.queryPlugin(plugin.name),
                  child: Text(context.t.app.retry),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _confirmRemoveSource(plugin),
                  child: Text(actions.removeSource),
                ),
              ],
            ),
          ),
        ),
      );
    }

    for (final plugin in empty) {
      widgets.add(
        Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.outline,
            ),
            title: Text(
              statusTexts.empty.replaceFirst('{plugin}', plugin.name),
            ),
            dense: true,
          ),
        ),
      );
    }

    return widgets;
  }

  void _confirmRemoveSource(Plugin plugin) {
    KazumiDialog.show(
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final dialogTexts =
            dialogContext.t.library.info.sourceSheet.dialog;
        return AlertDialog(
          title: Text(dialogTexts.removeTitle),
          content: Text(
            dialogTexts.removeMessage
                .replaceFirst('{plugin}', plugin.name),
          ),
          actions: [
            TextButton(
              onPressed: KazumiDialog.dismiss,
              child: Text(
                dialogContext.t.app.cancel,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                KazumiDialog.dismiss();
                await ref
                    .read(pluginsControllerProvider.notifier)
                    .removePlugin(plugin);
                KazumiDialog.showToast(
                  message: dialogContext
                      .t.library.info.sourceSheet.toast.removed
                      .replaceFirst('{plugin}', plugin.name),
                );
              },
              child: Text(dialogContext.t.app.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pluginState = ref.watch(pluginsControllerProvider);
    final plugins = pluginState.pluginList;

    if (plugins.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final searchState = ref.watch(sourceSearchProvider(_originalKeyword));
    final searchController =
        ref.read(sourceSearchProvider(_originalKeyword).notifier);

    final aggregation = _aggregateResults(plugins, searchState);
    final sortedEntries = _sortedEntries(aggregation.entries);
    final statusCards = _buildStatusCards(
      pending: aggregation.pending,
      errors: aggregation.errors,
      empty: aggregation.empty,
      controller: searchController,
    );

    final bangumiName = widget.infoController.bangumiItem.nameCn.isEmpty
        ? widget.infoController.bangumiItem.name
        : widget.infoController.bangumiItem.nameCn;

    final sheetTexts = context.t.library.info.sourceSheet;

    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    searchController.searchWithKeyword(_originalKeyword),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(sheetTexts.actions.searchAgain),
              ),
              OutlinedButton.icon(
                onPressed: _hasAlias
                    ? () => _showAliasSearchDialog(searchController)
                    : null,
                icon: const Icon(Icons.badge_outlined),
                label: Text(sheetTexts.actions.aliasSearch),
              ),
            ],
          ),
        ),
      ),
    ];

    if (statusCards.isNotEmpty) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(statusCards),
          ),
        ),
      );
    }

    if (sortedEntries.isNotEmpty) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const minTileWidth = 280.0;
                const spacing = 16.0;
                final maxWidth = constraints.maxWidth;
                var crossAxisCount =
                    ((maxWidth + spacing) / (minTileWidth + spacing)).floor();
                crossAxisCount = math.max(1, crossAxisCount);
                final totalSpacing = spacing * (crossAxisCount - 1);
                final itemWidth =
                    (maxWidth - totalSpacing) / crossAxisCount;

                return Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final entry in sortedEntries)
                        SizedBox(
                          width: itemWidth,
                          child: _buildSourceCard(
                            context,
                            entry.plugin,
                            entry.item,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else if (aggregation.pending.isNotEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              Text(sheetTexts.empty.searching),
            ],
          ),
        ),
      );
    } else {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              sheetTexts.empty.noResults,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          sheetTexts.title.replaceFirst('{name}', bangumiName),
        ),
        actions: [
          _buildSortMenu(),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: slivers,
      ),
    );
  }
}

class _SourceEntry {
  const _SourceEntry(this.plugin, this.item);

  final Plugin plugin;
  final SearchItem item;
}
