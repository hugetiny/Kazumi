import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:path_provider/path_provider.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugin_validity_tracker.dart';
import 'package:kazumi/plugins/plugin_install_time_tracker.dart';
import 'package:kazumi/request/plugin.dart';
import 'package:kazumi/modules/plugin/plugin_http_module.dart';
import 'package:logger/logger.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/request/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 从 1.5.1 版本开始，规则文件储存在单一的 plugins.json 文件中。
// 之前的版本中，规则以分离文件形式存储，版本更新后将这些分离文件合并为单一的 plugins.json 文件。

class PluginsState {
  const PluginsState({
    this.pluginList = const [],
    this.pluginHTTPList = const [],
  });

  final List<Plugin> pluginList;
  final List<PluginHTTPItem> pluginHTTPList;

  PluginsState copyWith({
    List<Plugin>? pluginList,
    List<PluginHTTPItem>? pluginHTTPList,
  }) {
    return PluginsState(
      pluginList: pluginList ?? this.pluginList,
      pluginHTTPList: pluginHTTPList ?? this.pluginHTTPList,
    );
  }
}

class PluginsController extends Notifier<PluginsState> {
  bool _isDisposed = false;

  @override
  PluginsState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });
    Future.microtask(init);
    return const PluginsState();
  }

  // 规则有效性追踪器
  final validityTracker = PluginValidityTracker();

  // 规则安装时间追踪器
  final installTimeTracker = PluginInstallTimeTracker();

  String pluginsFileName = "plugins.json";

  Directory? oldPluginDirectory;

  Directory? newPluginDirectory;

  List<Plugin> get pluginList => state.pluginList;

  List<PluginHTTPItem> get pluginHTTPList => state.pluginHTTPList;

  // Initializes the plugin directory and loads all plugins
  Future<void> init() async {
    final directory = await getApplicationSupportDirectory();
    oldPluginDirectory = Directory('${directory.path}/plugins');
    if (!await oldPluginDirectory!.exists()) {
      await oldPluginDirectory!.create(recursive: true);
    }
    newPluginDirectory = Directory('${directory.path}/plugins/v2');
    if (!await newPluginDirectory!.exists()) {
      await newPluginDirectory!.create(recursive: true);
    }
    await loadAllPlugins();
  }

  // Loads all plugins from the directory, populates the plugin list, and saves to plugins.json if needed
  Future<void> loadAllPlugins() async {
    KazumiLogger()
        .log(Level.info, 'Plugins Directory: ${newPluginDirectory!.path}');
    if (await newPluginDirectory!.exists()) {
      final pluginsFile = File('${newPluginDirectory!.path}/$pluginsFileName');
      if (await pluginsFile.exists()) {
        final jsonString = await pluginsFile.readAsString();
        final plugins = getPluginListFromJson(jsonString);
        _setPluginList(plugins);
        KazumiLogger()
            .log(Level.info, 'Current Plugin number: ${plugins.length}');
      } else {
        // No plugins.json
        var jsonFiles = await getPluginFiles();
        final List<Plugin> plugins = [];
        for (var filePath in jsonFiles) {
          final file = File(filePath);
          final jsonString = await file.readAsString();
          final data = jsonDecode(jsonString);
          final plugin = Plugin.fromJson(data);
          plugins.add(plugin);
          await file.delete(recursive: true);
        }
        _setPluginList(plugins);
        savePlugins();
      }
    } else {
      KazumiLogger().log(Level.warning, 'Plugin directory does not exist');
    }
  }

  // Retrieves a list of JSON plugin file paths from the plugin directory
  Future<List<String>> getPluginFiles() async {
    if (await oldPluginDirectory!.exists()) {
      final jsonFiles = oldPluginDirectory!
          .listSync()
          .where((file) => file.path.endsWith('.json') && file is File)
          .map((file) => file.path)
          .toList();
      return jsonFiles;
    } else {
      return [];
    }
  }

  // Copies plugin JSON files from the assets to the plugin directory
  Future<void> copyPluginsToExternalDirectory() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = assetManifest.listAssets();
    final jsonFiles = assets.where((String asset) =>
        asset.startsWith('assets/plugins/') && asset.endsWith('.json'));

    final List<Plugin> plugins = [...pluginList];
    for (var filePath in jsonFiles) {
      final jsonString = await rootBundle.loadString(filePath);
      final plugin = Plugin.fromJson(jsonDecode(jsonString));
      plugins.add(plugin);
    }
    _setPluginList(plugins);
    await savePlugins();
    KazumiLogger().log(Level.info,
        '${jsonFiles.length} plugin files copied to ${newPluginDirectory!.path}');
  }

  List<dynamic> pluginListToJson() {
    final List<dynamic> json = [];
    for (var plugin in pluginList) {
      json.add(plugin.toJson());
    }
    return json;
  }

  // Converts a JSON string into a list of Plugin objects.
  List<Plugin> getPluginListFromJson(String jsonString) {
    List<dynamic> json = jsonDecode(jsonString);
    List<Plugin> plugins = [];
    for (var j in json) {
      plugins.add(Plugin.fromJson(j));
    }
    return plugins;
  }

  Future<void> removePlugin(Plugin plugin) async {
    final updated = pluginList.where((p) => p.name != plugin.name).toList();
    _setPluginList(updated);
    await savePlugins();
  }

  // Update or add plugin
  void updatePlugin(Plugin plugin) {
    final updated = [...pluginList];
    final index = updated.indexWhere((p) => p.name == plugin.name);
    if (index >= 0) {
      updated[index] = plugin;
    } else {
      updated.add(plugin);
    }
    _setPluginList(updated);
    savePlugins();
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final updated = [...pluginList];
    final plugin = updated.removeAt(oldIndex);
    updated.insert(newIndex, plugin);
    _setPluginList(updated);
    savePlugins();
  }

  Future<void> savePlugins() async {
    final jsonData = jsonEncode(pluginListToJson());
    final pluginsFile = File('${newPluginDirectory!.path}/$pluginsFileName');
    await pluginsFile.writeAsString(jsonData);
  KazumiLogger().log(Level.info, '已更新源文件 $pluginsFileName');
  }

  Future<void> queryPluginHTTPList() async {
    var pluginHTTPListRes = await PluginHTTP.getPluginList();
    if (_isDisposed) {
      return;
    }
    state = state.copyWith(
      pluginHTTPList: List<PluginHTTPItem>.unmodifiable(pluginHTTPListRes),
    );
  }

  Future<Plugin?> queryPluginHTTP(String name) async {
    Plugin? plugin;
    plugin = await PluginHTTP.getPlugin(name);
    return plugin;
  }

  String pluginStatus(PluginHTTPItem pluginHTTPItem) {
    String pluginStatus = 'install';
    for (Plugin plugin in pluginList) {
      if (pluginHTTPItem.name == plugin.name) {
        if (pluginHTTPItem.version == plugin.version) {
          pluginStatus = 'installed';
        } else {
          pluginStatus = 'update';
        }
        break;
      }
    }
    return pluginStatus;
  }

  String pluginUpdateStatus(Plugin plugin) {
    if (!pluginHTTPList.any((p) => p.name == plugin.name)) {
      return "nonexistent";
    }
    PluginHTTPItem p = pluginHTTPList.firstWhere(
      (p) => p.name == plugin.name,
    );
    return p.version == plugin.version ? "latest" : "updatable";
  }

  Future<int> tryUpdatePlugin(Plugin plugin) async {
    return await tryUpdatePluginByName(plugin.name);
  }

  Future<int> tryUpdatePluginByName(String name) async {
    var pluginHTTPItem = await queryPluginHTTP(name);
    if (pluginHTTPItem != null) {
      if (int.parse(pluginHTTPItem.api) > Api.apiLevel) {
        return 1;
      }
      updatePlugin(pluginHTTPItem);
      return 0;
    }
    return 2;
  }

  Future<int> tryUpdateAllPlugin() async {
    int count = 0;
    for (Plugin plugin in pluginList) {
      if (pluginUpdateStatus(plugin) == 'updatable') {
        if (await tryUpdatePlugin(plugin) == 0) {
          count++;
        }
      }
    }
    return count;
  }

  void removePlugins(Set<String> pluginNames) {
    final updated = pluginList
        .where((plugin) => !pluginNames.contains(plugin.name))
        .toList();
    _setPluginList(updated);
    savePlugins();
  }

  void _setPluginList(List<Plugin> plugins) {
    if (_isDisposed) {
      return;
    }
    state = state.copyWith(
      pluginList: List<Plugin>.unmodifiable(plugins),
    );
  }
}
