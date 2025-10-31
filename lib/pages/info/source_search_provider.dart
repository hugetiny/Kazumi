import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:logger/logger.dart';

enum PluginSearchStatus { pending, success, error }

class SourceSearchState {
  const SourceSearchState({
    required this.statuses,
    required this.results,
  });

  factory SourceSearchState.initial(Iterable<String> pluginNames) {
    final statusMap = <String, PluginSearchStatus>{
      for (final name in pluginNames) name: PluginSearchStatus.pending,
    };
    final resultMap = <String, List<SearchItem>>{
      for (final name in pluginNames) name: const [],
    };
    return SourceSearchState(statuses: statusMap, results: resultMap);
  }

  final Map<String, PluginSearchStatus> statuses;
  final Map<String, List<SearchItem>> results;

  SourceSearchState setStatus(String pluginName, PluginSearchStatus status) {
    final updatedStatuses = Map<String, PluginSearchStatus>.from(statuses)
      ..[pluginName] = status;
    return SourceSearchState(statuses: updatedStatuses, results: results);
  }

  SourceSearchState setResults(String pluginName, List<SearchItem> data) {
    final updatedResults = Map<String, List<SearchItem>>.from(results)
      ..[pluginName] = List<SearchItem>.unmodifiable(data);
    return SourceSearchState(statuses: statuses, results: updatedResults);
  }

  SourceSearchState removePlugins(Iterable<String> pluginNames) {
    final names = pluginNames.toSet();
    final updatedStatuses = Map<String, PluginSearchStatus>.from(statuses)
      ..removeWhere((key, _) => names.contains(key));
    final updatedResults = Map<String, List<SearchItem>>.from(results)
      ..removeWhere((key, _) => names.contains(key));
    return SourceSearchState(
      statuses: updatedStatuses,
      results: updatedResults,
    );
  }

  SourceSearchState addPlugins(Iterable<String> pluginNames) {
    if (pluginNames.isEmpty) {
      return this;
    }
    final updatedStatuses = Map<String, PluginSearchStatus>.from(statuses);
    final updatedResults = Map<String, List<SearchItem>>.from(results);
    for (final name in pluginNames) {
      updatedStatuses[name] = PluginSearchStatus.pending;
      updatedResults[name] = const <SearchItem>[];
    }
    return SourceSearchState(
      statuses: updatedStatuses,
      results: updatedResults,
    );
  }
}

final sourceSearchProvider = AutoDisposeNotifierProviderFamily<
    SourceSearchController, SourceSearchState, String>(
  SourceSearchController.new,
);

class SourceSearchController
    extends AutoDisposeFamilyNotifier<SourceSearchState, String> {
  late final String _keyword;
  late String _activeKeyword;
  late final PluginsController _pluginsController;
  ProviderSubscription<PluginsState>? _pluginSubscription;
  bool _isDisposed = false;

  @override
  SourceSearchState build(String keyword) {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _pluginSubscription?.close();
      _pluginSubscription = null;
    });

    _keyword = keyword;
    _activeKeyword = keyword;
    _pluginsController = ref.read(pluginsControllerProvider.notifier);

    final pluginState = ref.read(pluginsControllerProvider);
    final initialNames =
        pluginState.pluginList.map((plugin) => plugin.name).toList();

    if (pluginState.pluginList.isNotEmpty) {
      Future.microtask(
        () => _queryAll(pluginState.pluginList, _keyword),
      );
    }

    _pluginSubscription = ref.listen<PluginsState>(
      pluginsControllerProvider,
      (previous, next) {
        if (_isDisposed) {
          return;
        }

        final prevNames = previous?.pluginList
                .map((plugin) => plugin.name)
                .toList() ??
            const [];
        final nextNames =
            next.pluginList.map((plugin) => plugin.name).toList();

        if (listEquals(prevNames, nextNames)) {
          return;
        }

        final prevSet = prevNames.toSet();
        final nextSet = nextNames.toSet();
        final removed = prevSet.difference(nextSet);
        final added = nextSet.difference(prevSet);

        var updatedState = state;
        if (removed.isNotEmpty) {
          updatedState = updatedState.removePlugins(removed);
        }
        if (added.isNotEmpty) {
          updatedState = updatedState.addPlugins(added);
        }
        state = updatedState;

        if (added.isEmpty) {
          return;
        }

        final newPlugins = next.pluginList
            .where((plugin) => added.contains(plugin.name))
            .toList();
        if (newPlugins.isNotEmpty) {
          for (final plugin in newPlugins) {
            unawaited(
              _queryPlugin(
                plugin,
                _activeKeyword,
                clearExisting: true,
              ),
            );
          }
        }
      },
      fireImmediately: false,
    );

    return SourceSearchState.initial(initialNames);
  }

  Future<void> queryPlugin(
    String pluginName, {
    String? keywordOverride,
  }) async {
    final plugin = _findPlugin(pluginName);
    if (plugin == null) {
      return;
    }
    await _queryPlugin(
      plugin,
      keywordOverride ?? _keyword,
      clearExisting: true,
    );
  }

  Future<void> refresh() async {
    final pluginList = _pluginsController.pluginList;
    if (pluginList.isEmpty) {
      return;
    }
    await _queryAll(pluginList, _activeKeyword);
  }

  Future<void> searchWithKeyword(String keyword) async {
    final pluginList = _pluginsController.pluginList;
    if (pluginList.isEmpty) {
      return;
    }
    await _queryAll(pluginList, keyword);
  }

  Future<void> _queryAll(List<Plugin> pluginList, String keyword) async {
    _activeKeyword = keyword;
    for (final plugin in pluginList) {
      _markPending(plugin.name, clearExisting: true);
    }

    final tasks = pluginList
        .map((plugin) => _queryPlugin(plugin, keyword, clearExisting: false))
        .toList();
    await Future.wait(tasks);
  }

  Future<void> _queryPlugin(
    Plugin plugin,
    String keyword, {
    required bool clearExisting,
  }) async {
    if (_isDisposed) {
      return;
    }

    _markPending(plugin.name, clearExisting: clearExisting);

    try {
      final response =
          await plugin.queryBangumi(keyword, shouldRethrow: true);
      if (_isDisposed) {
        return;
      }
      if (response.data.isNotEmpty) {
        _pluginsController.validityTracker.markSearchValid(plugin.name);
      }
      _markSuccess(plugin.name, response.data);
    } catch (error) {
      if (_isDisposed) {
        return;
      }
      KazumiLogger().log(
        Level.warning,
        '源 ${plugin.name} 检索失败: $error',
      );
      _markError(plugin.name);
    }
  }

  void _markPending(String pluginName, {required bool clearExisting}) {
    var updatedState = state.setStatus(pluginName, PluginSearchStatus.pending);
    if (clearExisting) {
      updatedState = updatedState.setResults(pluginName, const []);
    }
    state = updatedState;
  }

  void _markSuccess(String pluginName, List<SearchItem> data) {
    state = state
        .setStatus(pluginName, PluginSearchStatus.success)
        .setResults(pluginName, data);
  }

  void _markError(String pluginName) {
    state = state.setStatus(pluginName, PluginSearchStatus.error);
  }

  Plugin? _findPlugin(String name) {
    for (final plugin in _pluginsController.pluginList) {
      if (plugin.name == name) {
        return plugin;
      }
    }
    return null;
  }
}
