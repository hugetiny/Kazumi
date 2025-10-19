import 'dart:async';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/plugins/plugins_controller.dart';

class QueryManager {
  QueryManager({
    required this.infoController,
    required this.pluginsController,
  });

  final InfoController infoController;
  final PluginsController pluginsController;
  StreamController<PluginSearchResponse>? _controller;
  bool _isCancelled = false;

  Future<void> querySource(String keyword, String pluginName) async {
    final responses = infoController.pluginSearchResponseList;
    final existingIndex =
        responses.indexWhere((response) => response.pluginName == pluginName);
    if (existingIndex != -1) {
      responses.removeAt(existingIndex);
    }
    infoController.pluginSearchStatus[pluginName] = 'pending';
    for (Plugin plugin in pluginsController.pluginList) {
      if (plugin.name == pluginName) {
        plugin.queryBangumi(keyword, shouldRethrow: true).then((result) {
          if (_isCancelled) return;

          infoController.pluginSearchStatus[plugin.name] = 'success';
          if (result.data.isNotEmpty) {
            pluginsController.validityTracker.markSearchValid(plugin.name);
          }
          infoController.pluginSearchResponseList.add(result);
        }).catchError((error) {
          if (_isCancelled) return;

          infoController.pluginSearchStatus[plugin.name] = 'error';
        });
      }
    }
  }

  Future<void> queryAllSource(String keyword) async {
  _controller = StreamController<PluginSearchResponse>();
    infoController.pluginSearchResponseList.clear();

    for (Plugin plugin in pluginsController.pluginList) {
      infoController.pluginSearchStatus[plugin.name] = 'pending';
    }

    for (Plugin plugin in pluginsController.pluginList) {
      if (_isCancelled) return;

      plugin.queryBangumi(keyword, shouldRethrow: true).then((result) {
        if (_isCancelled) return;

        infoController.pluginSearchStatus[plugin.name] = 'success';
        if (result.data.isNotEmpty) {
          pluginsController.validityTracker.markSearchValid(plugin.name);
        }
  _controller?.add(result);
      }).catchError((error) {
        if (_isCancelled) return;

        infoController.pluginSearchStatus[plugin.name] = 'error';
      });
    }

    final controller = _controller;
    if (controller == null) {
      return;
    }
    await for (var result in controller.stream) {
      if (_isCancelled) break;

      infoController.pluginSearchResponseList.add(result);
    }
  }

  void cancel() {
    _isCancelled = true;
    _controller?.close();
    _controller = null;
  }
}
