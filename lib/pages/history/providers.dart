import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_controller.dart';

/// 观看历史 Provider
///
/// 管理用户的观看历史记录。
/// 支持历史记录的查询、删除和同步。
///
/// 示例:
/// ```dart
/// final controller = ref.read(historyProvider.notifier);
/// controller.loadHistory();
/// ```
final historyProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);
