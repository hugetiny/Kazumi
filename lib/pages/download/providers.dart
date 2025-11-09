import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/download/download_controller.dart';

final downloadControllerProvider =
    StateNotifierProvider<DownloadController, DownloadState>((ref) {
  return DownloadController();
});
