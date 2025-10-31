import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'popular_controller.dart';

/// 热门番剧列表 Provider
///
/// 管理热门页面的番剧列表加载，支持按标签筛选和趋势排序。
/// 支持分页加载和下拉刷新。
///
/// 示例:
/// ```dart
/// final controller = ref.read(popularProvider.notifier);
/// await controller.queryBangumiByTrend(type: 'init');
/// ```
final popularProvider =
    NotifierProvider<PopularController, PopularState>(PopularController.new);
