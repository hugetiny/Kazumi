import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/video/video_state.dart';

final videoControllerProvider =
    NotifierProvider<VideoPageController, VideoPageState>(
  VideoPageController.new,
);