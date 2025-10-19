import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeline_controller.dart';

final timelineControllerProvider =
		StateNotifierProvider<TimelineController, TimelineState>((ref) {
	return TimelineController();
});

