import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/anime_season.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimelineState {
  final List<List<BangumiItem>> bangumiCalendar;
  final String seasonString;
  final bool isLoading;
  final bool isTimeOut;
  final int sortType; // 1 default 2 score 3 heat
  final DateTime selectedDate;

  TimelineState({
    this.bangumiCalendar = const [],
    this.seasonString = '',
    this.isLoading = false,
    this.isTimeOut = false,
    this.sortType = 1,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  TimelineState copyWith({
    List<List<BangumiItem>>? bangumiCalendar,
    String? seasonString,
    bool? isLoading,
    bool? isTimeOut,
    int? sortType,
    DateTime? selectedDate,
  }) => TimelineState(
        bangumiCalendar: bangumiCalendar ?? this.bangumiCalendar,
        seasonString: seasonString ?? this.seasonString,
        isLoading: isLoading ?? this.isLoading,
        isTimeOut: isTimeOut ?? this.isTimeOut,
        sortType: sortType ?? this.sortType,
        selectedDate: selectedDate ?? this.selectedDate,
      );
}

class TimelineController extends Notifier<TimelineState> {
  @override
  TimelineState build() => TimelineState();

  Future<void> init() async {
    final now = DateTime.now();
    state = state.copyWith(
      selectedDate: now,
      seasonString: AnimeSeason(now).toString(),
    );
    await getSchedules();
  }

  Future<void> getSchedules() async {
    state = state.copyWith(isLoading: true, isTimeOut: false, bangumiCalendar: []);
    final res = await BangumiHTTP.getCalendar();
    final sorted = _sortCalendar(res, state.sortType);
    state = state.copyWith(
      bangumiCalendar: sorted,
      isLoading: false,
      isTimeOut: res.isEmpty,
    );
  }

  Future<void> getSchedulesBySeason() async {
    state = state.copyWith(isLoading: true, isTimeOut: false, bangumiCalendar: []);
    const maxTime = 4;
    const limit = 20;
    var aggregated = List.generate(7, (_) => <BangumiItem>[]);
    for (var time = 0; time < maxTime; time++) {
      final offset = time * limit;
      final newList = await BangumiHTTP.getCalendarBySearch(
        AnimeSeason(state.selectedDate).toSeasonStartAndEnd(),
        limit,
        offset,
      );
      for (int i = 0; i < aggregated.length; ++i) {
        aggregated[i].addAll(newList[i]);
      }
      state = state.copyWith(bangumiCalendar: aggregated.map((e) => [...e]).toList());
    }
    final empty = aggregated.every((l) => l.isEmpty);
    if (!empty) {
      aggregated = _sortCalendar(aggregated, state.sortType);
    }
    state = state.copyWith(
      bangumiCalendar: aggregated,
      isLoading: false,
      isTimeOut: empty,
    );
  }

  void tryEnterSeason(DateTime date) {
    state = state.copyWith(selectedDate: date, seasonString: '加载中 ٩(◦`꒳´◦)۶');
  }

  void changeSortType(int type) {
    if (type < 1 || type > 3) return;
    final sorted = _sortCalendar(state.bangumiCalendar, type);
    state = state.copyWith(sortType: type, bangumiCalendar: sorted);
  }

  List<List<BangumiItem>> _sortCalendar(List<List<BangumiItem>> calendar, int sortType) {
    final copy = calendar.map((d) => [...d]).toList();
    for (var dayList in copy) {
      switch (sortType) {
        case 1:
          dayList.sort((a, b) => a.id.compareTo(b.id));
          break;
        case 2:
          dayList.sort((a, b) => (b.ratingScore).compareTo(a.ratingScore));
          break;
        case 3:
          dayList.sort((a, b) => (b.votes).compareTo(a.votes));
          break;
      }
    }
    return copy;
  }

  void finalizeSeasonString() {
    state = state.copyWith(
      seasonString: AnimeSeason(state.selectedDate).toString(),
    );
  }
}

