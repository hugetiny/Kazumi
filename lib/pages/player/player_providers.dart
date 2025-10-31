import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/player/player_controller.dart';
import 'package:kazumi/pages/player/player_state.dart';

/// 播放器控制 Provider
///
/// 管理 media-kit 播放器实例、弹幕、字幕和播放控制。
/// 支持画面比例、倍速、滤镜和 SyncPlay 同步。
///
/// 示例:
/// ```dart
/// final controller = ref.read(playerProvider.notifier);
/// await controller.playVideo(url, bangumiId);
/// ```
final playerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);
