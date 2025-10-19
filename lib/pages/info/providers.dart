import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/collect/providers.dart';
import 'package:kazumi/pages/info/info_controller.dart';

final infoControllerProvider =
    StateNotifierProvider<InfoController, InfoState>((ref) {
  final collect = ref.read(collectControllerProvider.notifier);
  return InfoController(collectController: collect);
});