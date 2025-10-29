import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_controller.dart';

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);

