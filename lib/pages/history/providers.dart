import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_controller.dart';

final historyControllerProvider =
		StateNotifierProvider<HistoryController, HistoryState>((ref) {
	return HistoryController()..init();
});

