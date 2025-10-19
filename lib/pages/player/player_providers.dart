import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/player/player_controller.dart';
import 'package:kazumi/pages/player/player_state.dart';

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>((ref) {
  final controller = PlayerController(ref);
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
