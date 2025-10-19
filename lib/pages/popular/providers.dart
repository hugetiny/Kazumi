import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'popular_controller.dart';

/// Popular 页面 controller provider
final popularControllerProvider =
		StateNotifierProvider<PopularController, PopularState>((ref) {
	return PopularController();
});

