import 'dart:ui' as ui;

import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/modules/characters/character_item.dart';
import 'package:kazumi/modules/metadata_sync/metadata_sync_controller.dart';
import 'package:kazumi/modules/metadata_sync/models/metadata_record.dart';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/modules/staff/staff_item.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/pages/my/providers.dart';
import 'package:kazumi/providers/media_suite_providers.dart';
import 'package:kazumi/request/bangumi.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class InfoState {
  final bool isLoading;
  final bool metadataLoading;
  final List<CommentItem> commentsList;
  final List<CharacterItem> characterList;
  final List<StaffFullItem> staffList;
  final BangumiItem? bangumiItem;
  final MetadataRecord? metadataRecord;

  const InfoState({
    this.isLoading = false,
    this.metadataLoading = false,
    this.commentsList = const [],
    this.characterList = const [],
    this.staffList = const [],
    this.bangumiItem,
    this.metadataRecord,
  });

  InfoState copyWith({
    bool? isLoading,
    bool? metadataLoading,
    List<CommentItem>? commentsList,
    List<CharacterItem>? characterList,
    List<StaffFullItem>? staffList,
    BangumiItem? bangumiItem,
    MetadataRecord? metadataRecord,
  }) {
    return InfoState(
      isLoading: isLoading ?? this.isLoading,
      metadataLoading: metadataLoading ?? this.metadataLoading,
      commentsList: commentsList ?? this.commentsList,
      characterList: characterList ?? this.characterList,
      staffList: staffList ?? this.staffList,
      bangumiItem: bangumiItem ?? this.bangumiItem,
      metadataRecord: metadataRecord ?? this.metadataRecord,
    );
  }
}

class InfoController extends Notifier<InfoState> {
  late final CollectController collectController;
  late final MetadataSyncController _metadataSyncController;

  @override
  InfoState build() {
    collectController = ref.read(collectControllerProvider.notifier);
    _metadataSyncController = ref.read(metadataSyncControllerProvider);
    return const InfoState();
  }
  final List<PluginSearchResponse> _legacyPluginSearchResponses = [];
  final Map<String, String> _legacyPluginSearchStatus = {};

  BangumiItem get bangumiItem => state.bangumiItem ?? _emptyBangumiItem;

  set bangumiItem(BangumiItem item) {
    state = state.copyWith(bangumiItem: item);
  }

  MetadataRecord? get metadataRecord => state.metadataRecord;

  List<CommentItem> get commentsList => state.commentsList;
  List<CharacterItem> get characterList => state.characterList;
  List<StaffFullItem> get staffList => state.staffList;
  bool get isLoading => state.isLoading;
  bool get metadataLoading => state.metadataLoading;

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
      await refreshMetadata(forceRefresh: type != 'init');
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshMetadata({bool forceRefresh = false}) async {
    final BangumiItem current = bangumiItem;
    if (current.id == 0) {
      return;
    }
    state = state.copyWith(metadataLoading: true);
    final ui.Locale? localeOverride = _resolvePreferredLocale();
    try {
      final MetadataRecord? record = await _metadataSyncController.ensureLatest(
        current.id.toString(),
        forceRefresh: forceRefresh,
        localeOverride: localeOverride,
      );
      if (record != null) {
        final BangumiItem merged = _mergeMetadata(current, record);
        await collectController.updateLocalCollect(merged);
        state = state.copyWith(
          bangumiItem: merged,
          metadataRecord: record,
          metadataLoading: false,
        );
      } else {
        state = state.copyWith(metadataLoading: false);
      }
    } catch (error, stackTrace) {
      KazumiLogger().log(
        Level.warning,
        '[InfoController] Metadata refresh failed for bangumi ${current.id}: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(metadataLoading: false);
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

  BangumiItem _mergeMetadata(BangumiItem base, MetadataRecord record) {
    final String displayLocale = _resolveDisplayLocaleTag(record);
    final String preferredTitle =
        record.displayTitleForLocale(displayLocale).trim();
    final String? synopsis =
        record.synopsisForLocale(displayLocale) ?? record.synopsis[record.localeTag];
    final Map<String, String> images = Map<String, String>.from(base.images);
    if (record.posterUrl != null && record.posterUrl!.isNotEmpty) {
      images['large'] = record.posterUrl!;
      images['common'] = record.posterUrl!;
    }
    if (record.backdropUrl != null && record.backdropUrl!.isNotEmpty) {
      images['backdrop'] = record.backdropUrl!;
    }
    return BangumiItem(
      id: base.id,
      type: base.type,
      name: preferredTitle.isNotEmpty ? preferredTitle : base.name,
      nameCn: preferredTitle.isNotEmpty ? preferredTitle : base.nameCn,
      summary: synopsis?.trim().isNotEmpty == true ? synopsis!.trim() : base.summary,
      airDate: base.airDate,
      airWeekday: base.airWeekday,
      rank: base.rank,
      images: images,
      tags: base.tags,
      alias: base.alias,
      ratingScore: base.ratingScore,
      votes: base.votes,
      votesCount: base.votesCount,
      info: base.info,
    );
  }

  ui.Locale? _resolvePreferredLocale() {
    final String? stored = GStorage.setting
            .get(SettingBoxKey.metadataPreferredLocale, defaultValue: '')
        as String?;
    if (stored == null || stored.isEmpty) {
      return null;
    }
    final List<String> segments = stored.split('-');
    if (segments.isEmpty) {
      return null;
    }
    if (segments.length == 1) {
      return ui.Locale(segments.first);
    }
    String? scriptCode;
    String? countryCode;
    for (final String segment in segments.skip(1)) {
      if (segment.length == 4 && scriptCode == null) {
        scriptCode = segment;
      } else if (countryCode == null) {
        countryCode = segment;
      }
    }
    return ui.Locale.fromSubtags(
      languageCode: segments[0],
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }

  String _resolveDisplayLocaleTag(MetadataRecord record) {
    if (record.localeTag.isNotEmpty) {
      return record.localeTag;
    }
    final ui.Locale? preferred = _resolvePreferredLocale();
    if (preferred != null) {
      return preferred.toLanguageTag();
    }
    return ui.PlatformDispatcher.instance.locale.toLanguageTag();
  }
}
