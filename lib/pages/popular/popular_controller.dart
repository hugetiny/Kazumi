import 'dart:math';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

/// Popular 页面所需的全部状态
class PopularState {
  final String currentTag;
  final List<BangumiItem> bangumiList; // 按标签获取的番组
  final List<BangumiItem> trendList; // 热门趋势番组
  final double scrollOffset;
  final bool isLoadingMore;
  final bool isTimeOut;

  const PopularState({
    this.currentTag = '',
    this.bangumiList = const [],
    this.trendList = const [],
    this.scrollOffset = 0.0,
    this.isLoadingMore = false,
    this.isTimeOut = false,
  });

  PopularState copyWith({
    String? currentTag,
    List<BangumiItem>? bangumiList,
    List<BangumiItem>? trendList,
    double? scrollOffset,
    bool? isLoadingMore,
    bool? isTimeOut,
  }) {
    return PopularState(
      currentTag: currentTag ?? this.currentTag,
      bangumiList: bangumiList ?? this.bangumiList,
      trendList: trendList ?? this.trendList,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isTimeOut: isTimeOut ?? this.isTimeOut,
    );
  }
}

/// 负责处理热门番组/标签番组的加载逻辑
/// 迁移自 MobX -> Riverpod StateNotifier
class PopularController extends SafeStateNotifier<PopularState> {
  PopularController() : super(const PopularState());

  void setCurrentTag(String tag) {
    state = state.copyWith(currentTag: tag);
  }

  void clearBangumiList() {
    state = state.copyWith(bangumiList: []);
  }

  void updateScrollOffset(double offset) {
    // 仅在数值有明显变化时更新，避免频繁 rebuild
    if ((offset - state.scrollOffset).abs() > 8) {
      state = state.copyWith(scrollOffset: offset);
    }
  }

  Future<void> queryBangumiByTrend({String type = 'add'}) async {
    if (state.isLoadingMore) return;
    List<BangumiItem> trendList = state.trendList;
    if (type == 'init') {
      trendList = [];
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await BangumiHTTP.getBangumiTrendsList(offset: trendList.length);
      trendList = [...trendList, ...result];
      state = state.copyWith(
        trendList: trendList,
        isLoadingMore: false,
        isTimeOut: trendList.isEmpty,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false, isTimeOut: trendList.isEmpty);
    }
  }

  Future<void> queryBangumiByTag({String type = 'add'}) async {
    if (state.isLoadingMore) return;
    List<BangumiItem> bangumiList = state.bangumiList;
    if (type == 'init') {
      bangumiList = [];
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      int randomNumber = Random().nextInt(8000) + 1;
      final result = await BangumiHTTP.getBangumiList(
        rank: randomNumber,
        tag: state.currentTag,
      );
      bangumiList = [...bangumiList, ...result];
      state = state.copyWith(
        bangumiList: bangumiList,
        isLoadingMore: false,
        isTimeOut: bangumiList.isEmpty,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false, isTimeOut: bangumiList.isEmpty);
    }
  }
}

