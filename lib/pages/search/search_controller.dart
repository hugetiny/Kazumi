import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/search_parser.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/modules/search/search_history_module.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

class SearchPageState {
  final bool isLoading;
  final bool isTimeOut;
  final List<BangumiItem> bangumiList;
  final List<SearchHistory> searchHistories;

  const SearchPageState({
    this.isLoading = false,
    this.isTimeOut = false,
    this.bangumiList = const [],
    this.searchHistories = const [],
  });

  SearchPageState copyWith({
    bool? isLoading,
    bool? isTimeOut,
    List<BangumiItem>? bangumiList,
    List<SearchHistory>? searchHistories,
  }) {
    return SearchPageState(
      isLoading: isLoading ?? this.isLoading,
      isTimeOut: isTimeOut ?? this.isTimeOut,
      bangumiList: bangumiList ?? this.bangumiList,
      searchHistories: searchHistories ?? this.searchHistories,
    );
  }
}

class SearchPageController extends SafeStateNotifier<SearchPageState> {
  final Box setting = GStorage.setting;
  final Box searchHistoryBox = GStorage.searchHistory;

  SearchPageController() : super(const SearchPageState());

  void loadSearchHistories() {
    var temp = searchHistoryBox.values.toList().cast<SearchHistory>();
    temp.sort(
      (a, b) => b.timestamp - a.timestamp,
    );
    state = state.copyWith(searchHistories: temp);
  }

  /// Avaliable sort parameters:
  /// 1. heat
  /// 2. match
  /// 3. rank
  /// 4. score
  String attachSortParams(String input, String sort) {
    SearchParser parser = SearchParser(input);
    String newInput = parser.updateSort(sort);
    return newInput;
  }

  Future<void> searchBangumi(String input, {String type = 'add'}) async {
    final normalizedInput = input.trim();
    if (normalizedInput.isEmpty) {
      state = state.copyWith(
        bangumiList: [],
        isLoading: false,
        isTimeOut: false,
      );
      return;
    }

    if (type != 'add') {
      state = state.copyWith(bangumiList: []);
      bool privateMode =
          await setting.get(SettingBoxKey.privateMode, defaultValue: false);
      if (!privateMode) {
        if (state.searchHistories.length >= 10) {
          await searchHistoryBox.delete(state.searchHistories.last.key);
        }
        final historiesToDelete =
            state.searchHistories.where((element) => element.keyword == normalizedInput);
        if (historiesToDelete.isNotEmpty) {
          for (var history in historiesToDelete) {
            await searchHistoryBox.delete(history.key);
          }
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await searchHistoryBox.put(
          timestamp.toString(),
          SearchHistory(normalizedInput, timestamp),
        );
        loadSearchHistories();
      }
    }
    state = state.copyWith(isLoading: true, isTimeOut: false);
    SearchParser parser = SearchParser(normalizedInput);
    String? idString = parser.parseId();
    String? tag = parser.parseTag();
    String? sort = parser.parseSort();
    String keywords = parser.parseKeywords();
    if (idString != null) {
  final id = int.tryParse(idString);
      if (id != null) {
        final BangumiItem? item = await BangumiHTTP.getBangumiInfoByID(id);
        if (item != null) {
          state = state.copyWith(
            bangumiList: [...state.bangumiList, item],
            isLoading: false,
            isTimeOut: false,
          );
        }
        return;
      }
    }
    var result = await BangumiHTTP.bangumiSearch(keywords,
        tags: [if (tag != null) tag],
        offset: state.bangumiList.length,
        sort: sort ?? 'heat');
    state = state.copyWith(
      bangumiList: [...state.bangumiList, ...result],
      isLoading: false,
      isTimeOut: [...state.bangumiList, ...result].isEmpty,
    );
  }

  Future<void> deleteSearchHistory(SearchHistory history) async {
    state = state.copyWith(
      searchHistories: state.searchHistories
          .where((element) => element.key != history.key)
          .toList(),
    );
    await searchHistoryBox.delete(history.key);
    // Fallback for legacy entries whose Hive key may differ from timestamp
    if (searchHistoryBox.containsKey(history.key)) {
      final fallbackKey = searchHistoryBox.keys.cast<dynamic>().firstWhere(
        (key) {
          final value = searchHistoryBox.get(key);
          return value is SearchHistory && value.timestamp == history.timestamp;
        },
        orElse: () => null,
      );
      if (fallbackKey != null) {
        await searchHistoryBox.delete(fallbackKey);
      }
    }
    loadSearchHistories();
  }

  Future<void> clearSearchHistory() async {
    await searchHistoryBox.clear();
    loadSearchHistories();
  }
}
