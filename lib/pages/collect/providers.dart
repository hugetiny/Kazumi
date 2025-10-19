import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'collect_controller.dart';

final collectControllerProvider =
    StateNotifierProvider<CollectController, CollectState>((ref) {
  return CollectController()..loadCollectibles();
});
