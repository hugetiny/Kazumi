import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/plugins/plugins_controller.dart';

final pluginsControllerProvider =
    NotifierProvider<PluginsController, PluginsState>(PluginsController.new);
