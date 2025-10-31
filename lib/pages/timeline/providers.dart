import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeline_controller.dart';

final timelineControllerProvider =
    NotifierProvider<TimelineController, TimelineState>(TimelineController.new);

