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
}

final sourceSearchProvider = StateNotifierProvider.autoDispose.family<
    SourceSearchController, SourceSearchState, String>(
  (ref, keyword) {
    final controller = SourceSearchController(ref, keyword);
    controller.initialize();
    return controller;
  },
);

class SourceSearchController extends StateNotifier<SourceSearchState> {
  SourceSearchController(this._ref, this._keyword)
      : super(_initialState(_ref));

  final AutoDisposeStateNotifierProviderRef<SourceSearchController,
      SourceSearchState> _ref;
  final String _keyword;

  bool _isDisposed = false;
  ProviderSubscription<PluginsState>? _pluginListenerCancel;

  static SourceSearchState _initialState(
      AutoDisposeStateNotifierProviderRef<SourceSearchController,
              SourceSearchState>
          ref) {
    final pluginState = ref.read(pluginsControllerProvider);
    final pluginNames = pluginState.pluginList.map((plugin) => plugin.name);
    return SourceSearchState.initial(pluginNames);
  }

  PluginsController get _pluginsController =>
      _ref.read(pluginsControllerProvider.notifier);

  void initialize() {
    final pluginState = _ref.read(pluginsControllerProvider);
    final pluginList = pluginState.pluginList;
    if (pluginList.isNotEmpty) {
      _queryAll(pluginList, _keyword);
    }

    _pluginListenerCancel = _ref.listen<PluginsState>(
      pluginsControllerProvider,
      (previous, next) {
        if (_isDisposed) return;
        final prevNames =
            previous?.pluginList.map((plugin) => plugin.name).toList() ?? const [];
        final nextNames =
            next.pluginList.map((plugin) => plugin.name).toList();

        if (!listEquals(prevNames, nextNames)) {
          state = SourceSearchState.initial(nextNames);
          if (next.pluginList.isNotEmpty) {
            _queryAll(next.pluginList, _keyword);
          }
        }
      },
      fireImmediately: false,
    );

    _ref.onDispose(() {
      _isDisposed = true;
      _pluginListenerCancel?.close();
    });
  }

  Future<void> queryPlugin(
    String pluginName, {
    String? keywordOverride,
  }) async {
    final plugin = _findPlugin(pluginName);
    if (plugin == null) {
      return;
    }
    await _queryPlugin(plugin, keywordOverride ?? _keyword,
        clearExisting: true);
  }

  Future<void> _queryAll(List<Plugin> pluginList, String keyword) async {
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
      KazumiLogger().log(Level.warning,
          '插件 ${plugin.name} 检索失败: $error');
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
