import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/modules/characters/character_item.dart';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/modules/staff/staff_item.dart';
import 'package:kazumi/pages/collect/collect_controller.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';
import 'package:logger/logger.dart';

class InfoState {
  final bool isLoading;
  final List<CommentItem> commentsList;
  final List<CharacterItem> characterList;
  final List<StaffFullItem> staffList;
  final BangumiItem? bangumiItem;

  const InfoState({
    this.isLoading = false,
    this.commentsList = const [],
    this.characterList = const [],
    this.staffList = const [],
    this.bangumiItem,
  });

  InfoState copyWith({
    bool? isLoading,
    List<CommentItem>? commentsList,
    List<CharacterItem>? characterList,
    List<StaffFullItem>? staffList,
    BangumiItem? bangumiItem,
  }) {
    return InfoState(
      isLoading: isLoading ?? this.isLoading,
      commentsList: commentsList ?? this.commentsList,
      characterList: characterList ?? this.characterList,
      staffList: staffList ?? this.staffList,
      bangumiItem: bangumiItem ?? this.bangumiItem,
    );
  }
}

class InfoController extends SafeStateNotifier<InfoState> {
  InfoController({required this.collectController})
      : super(const InfoState());

  final CollectController collectController;
  final List<PluginSearchResponse> _legacyPluginSearchResponses = [];
  final Map<String, String> _legacyPluginSearchStatus = {};

  BangumiItem get bangumiItem => state.bangumiItem ?? _emptyBangumiItem;

  set bangumiItem(BangumiItem item) {
    state = state.copyWith(bangumiItem: item);
  }

  List<CommentItem> get commentsList => state.commentsList;
  List<CharacterItem> get characterList => state.characterList;
  List<StaffFullItem> get staffList => state.staffList;
  bool get isLoading => state.isLoading;

  void clearComments() {
    if (state.commentsList.isEmpty) return;
    state = state.copyWith(commentsList: const []);
  }

  void clearCharacters() {
    if (state.characterList.isEmpty) return;
    state = state.copyWith(characterList: const []);
  }

  void clearStaff() {
    if (state.staffList.isEmpty) return;
    state = state.copyWith(staffList: const []);
  }

  void resetListsForNewBangumi() {
    state = state.copyWith(
      commentsList: const [],
      characterList: const [],
      staffList: const [],
    );
    _legacyPluginSearchResponses.clear();
    _legacyPluginSearchStatus.clear();
  }

  Future<void> queryBangumiInfoByID(int id, {String type = 'init'}) async {
    state = state.copyWith(isLoading: true);
    final value = await BangumiHTTP.getBangumiInfoByID(id);
    if (value != null) {
      BangumiItem updatedItem;
      if (type == 'init' || state.bangumiItem == null) {
        updatedItem = value;
      } else {
        final current = state.bangumiItem!;
        updatedItem = BangumiItem(
          id: current.id,
          type: current.type,
          name: current.name,
          nameCn: current.nameCn,
          summary: value.summary,
          airDate: value.airDate,
          airWeekday: value.airWeekday,
          rank: value.rank,
          images: current.images,
          tags: value.tags,
          alias: value.alias,
          ratingScore: value.ratingScore,
          votes: value.votes,
          votesCount: value.votesCount,
          info: current.info,
        );
      }
      await collectController.updateLocalCollect(updatedItem);
      state = state.copyWith(
        bangumiItem: updatedItem,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> queryBangumiCommentsByID(int id, {int offset = 0}) async {
    final existing =
        offset == 0 ? <CommentItem>[] : List<CommentItem>.from(state.commentsList);
    final result = await BangumiHTTP.getBangumiCommentsByID(id, offset: offset);
    final updated = [...existing, ...result.commentList];
    state = state.copyWith(commentsList: updated);
    KazumiLogger().log(Level.info, '已加载评论列表长度 ${updated.length}');
  }

  Future<void> queryBangumiCharactersByID(int id) async {
    final result = await BangumiHTTP.getCharatersByBangumiID(id);
    final characters = result.charactersList;
    const relationValue = {'主角': 1, '配角': 2, '客串': 3};

    try {
      characters.sort((a, b) {
        final valueA = relationValue[a.relation] ?? 4;
        final valueB = relationValue[b.relation] ?? 4;
        return valueA.compareTo(valueB);
      });
    } catch (e) {
      KazumiDialog.showToast(message: '$e');
    }
    state = state.copyWith(characterList: characters);
    KazumiLogger().log(Level.info, '已加载角色列表长度 ${characters.length}');
  }

  Future<void> queryBangumiStaffsByID(int id) async {
    final result = await BangumiHTTP.getBangumiStaffByID(id);
    final staff = result.data;
    state = state.copyWith(staffList: staff);
    KazumiLogger().log(Level.info, '已加载制作人员列表长度 ${staff.length}');
  }

  // Legacy accessors retained to avoid breakages; search functionality has moved
  // to dedicated Riverpod providers.
  List<PluginSearchResponse> get pluginSearchResponseList =>
      _legacyPluginSearchResponses;
  Map<String, String> get pluginSearchStatus => _legacyPluginSearchStatus;

  static final BangumiItem _emptyBangumiItem = BangumiItem(
    id: 0,
    type: 0,
    name: '',
    nameCn: '',
    summary: '',
    airDate: '',
    airWeekday: 0,
    rank: 0,
    images: {},
    tags: [],
    alias: [],
    ratingScore: 0,
    votes: 0,
    votesCount: [],
    info: '',
  );
}
