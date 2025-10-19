import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/plugins/plugins_controller.dart';

final pluginsControllerProvider =
    StateNotifierProvider<PluginsController, PluginsState>((ref) {
  final controller = PluginsController();
  controller.init();
  return controller;
});
