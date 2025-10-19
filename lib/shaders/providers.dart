import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/shaders/shaders_controller.dart';

final shadersControllerProvider = Provider<ShadersController>((ref) {
  return ShadersController();
});
