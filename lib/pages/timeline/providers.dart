import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeline_controller.dart';

/// 追番时间表 Provider
///
/// 管理每周番剧放送时间表数据。
/// 按星期组织番剧，支持快速查看本周更新。
///
/// 示例:
/// ```dart
/// final controller = ref.read(timelineProvider.notifier);
/// await controller.queryTimeline();
/// ```
final timelineProvider =
    NotifierProvider<TimelineController, TimelineState>(TimelineController.new);
