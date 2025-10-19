import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/history/history_module.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

class HistoryState {
  final List<History> histories;
  const HistoryState({this.histories = const []});

  HistoryState copyWith({List<History>? histories}) =>
      HistoryState(histories: histories ?? this.histories);
}

class HistoryController extends SafeStateNotifier<HistoryState> {
  HistoryController() : super(const HistoryState());

  Box get setting => GStorage.setting;
  Box<History> get storedHistories => GStorage.histories;

  void init() {
    final temp = storedHistories.values.toList()
      ..sort((a, b) => b.lastWatchTime.millisecondsSinceEpoch -
          a.lastWatchTime.millisecondsSinceEpoch);
    state = state.copyWith(histories: temp);
  }

  void updateHistory(
    int episode,
    int road,
    String adapterName,
    BangumiItem bangumiItem,
    Duration progress,
    String lastSrc,
    String lastWatchEpisodeName,
  ) {
    final privateMode = setting.get(SettingBoxKey.privateMode, defaultValue: false);
    if (privateMode) return;

    final key = History.getKey(adapterName, bangumiItem);
    final history = storedHistories.get(key) ??
        History(bangumiItem, episode, adapterName, DateTime.now(), lastSrc, lastWatchEpisodeName);

    history.lastWatchEpisode = episode;
    history.lastWatchTime = DateTime.now();
    if (lastSrc.isNotEmpty) history.lastSrc = lastSrc;
    if (lastWatchEpisodeName.isNotEmpty) history.lastWatchEpisodeName = lastWatchEpisodeName;

    final prog = history.progresses[episode];
    if (prog == null) {
      history.progresses[episode] = Progress(episode, road, progress.inMilliseconds);
    } else {
      prog.progress = progress;
    }

    storedHistories.put(history.key, history);
    init();
  }

  Progress? lastWatching(BangumiItem bangumiItem, String adapterName) {
    final history = storedHistories.get(History.getKey(adapterName, bangumiItem));
    return history?.progresses[history.lastWatchEpisode];
  }

  Progress? findProgress(BangumiItem bangumiItem, String adapterName, int episode) {
    final history = storedHistories.get(History.getKey(adapterName, bangumiItem));
    return history?.progresses[episode];
  }

  void deleteHistory(History history) {
    storedHistories.delete(history.key);
    init();
  }

  void clearProgress(BangumiItem bangumiItem, String adapterName, int episode) {
    final history = storedHistories.get(History.getKey(adapterName, bangumiItem));
    history?.progresses[episode]?.progress = Duration.zero;
    init();
  }

  void clearAll() {
    GStorage.histories.clear();
    state = state.copyWith(histories: []);
  }
}
