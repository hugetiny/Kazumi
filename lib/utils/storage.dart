import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/bangumi/bangumi_tag.dart';
import 'package:kazumi/modules/history/history_module.dart';
import 'package:kazumi/modules/collect/collect_module.dart';
import 'package:kazumi/modules/collect/collect_change_module.dart';
import 'package:kazumi/modules/search/search_history_module.dart';
import 'package:kazumi/modules/metadata_sync/models/metadata_record.dart';
import 'package:kazumi/modules/download/download_task.dart';
import 'package:kazumi/utils/api_credentials.dart';

class GStorage {
  /// Don't use favorites box, it's replaced by collectibles.
  static late Box<BangumiItem> favorites;
  static late Box<CollectedBangumi> collectibles;
  static late Box<History> histories;
  static late Box<CollectedBangumiChange> collectChanges;
  static late Box<String> shieldList;
  static late final Box<dynamic> setting;
  static late Box<SearchHistory> searchHistory;
  static late Box<MetadataRecord> metadataCache;
  static late Box<dynamic> downloadTasks;
  static late Box<dynamic> torrentEntries;
  static late Box<dynamic> playbackProfiles;

  static Future init() async {
    Hive.registerAdapter(BangumiItemAdapter());
    Hive.registerAdapter(BangumiTagAdapter());
    Hive.registerAdapter(CollectedBangumiAdapter());
    Hive.registerAdapter(ProgressAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(CollectedBangumiChangeAdapter());
    Hive.registerAdapter(SearchHistoryAdapter());
    Hive.registerAdapter(EpisodeMetadataAdapter());
    Hive.registerAdapter(MetadataSourceSnapshotAdapter());
    Hive.registerAdapter(MetadataRecordAdapter());
    Hive.registerAdapter(DownloadTaskAdapter());
    favorites = await Hive.openBox('favorites');
    collectibles = await Hive.openBox('collectibles');
    histories = await Hive.openBox('histories');
    setting = await Hive.openBox('setting');
    collectChanges = await Hive.openBox('collectchanges');
    shieldList = await Hive.openBox('shieldList');
    searchHistory = await Hive.openBox('searchHistory');
    metadataCache = await Hive.openBox<MetadataRecord>('metadataCache');
    downloadTasks = await Hive.openBox('downloadTasks');
    torrentEntries = await Hive.openBox('torrentEntries');
    playbackProfiles = await Hive.openBox('playbackProfiles');

    await _ensureRetentionDefaults();
  }

  static Future<void> backupBox(String boxName, String backupFilePath) async {
    final appDocumentDir = await getApplicationSupportDirectory();
    final hiveBoxFile = File('${appDocumentDir.path}/hive/$boxName.hive');
    if (await hiveBoxFile.exists()) {
      await hiveBoxFile.copy(backupFilePath);
      print('Backup success: $backupFilePath');
    } else {
      print('Hive box not exists');
    }
  }

  static Future<void> patchHistory(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    final backupContent = await backupFile.readAsBytes();
    final tempBox = await Hive.openBox('tempHistoryBox', bytes: backupContent);
    final tempBoxItems = tempBox.toMap().entries;

    for (var tempBoxItem in tempBoxItems) {
      if (histories.get(tempBoxItem.key) != null) {
        if (histories
            .get(tempBoxItem.key)!
            .lastWatchTime
            .isBefore(tempBoxItem.value.lastWatchTime)) {
          await histories.delete(tempBoxItem.key);
          await histories.put(tempBoxItem.key, tempBoxItem.value);
        }
      } else {
        await histories.put(tempBoxItem.key, tempBoxItem.value);
      }
    }
    await tempBox.close();
  }

  static Future<void> restoreCollectibles(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    final backupContent = await backupFile.readAsBytes();
    final tempBox =
        await Hive.openBox('tempCollectiblesBox', bytes: backupContent);
    final tempBoxItems = tempBox.toMap().entries;
    debugPrint('webDav源列表长度 ${tempBoxItems.length}');

    await collectibles.clear();
    for (var tempBoxItem in tempBoxItems) {
      await collectibles.put(tempBoxItem.key, tempBoxItem.value);
    }
    await tempBox.close();
  }

  static Future<List<CollectedBangumi>> getCollectiblesFromFile(
      String backupFilePath) async {
    final backupFile = File(backupFilePath);
    final backupContent = await backupFile.readAsBytes();
    final tempBox =
        await Hive.openBox('tempCollectiblesBox', bytes: backupContent);
    final tempBoxItems = tempBox.toMap().entries;
    debugPrint('webDav源列表长度 ${tempBoxItems.length}');

    final List<CollectedBangumi> collectibles = [];
    for (var tempBoxItem in tempBoxItems) {
      collectibles.add(tempBoxItem.value);
    }
    await tempBox.close();
    return collectibles;
  }

  static Future<List<CollectedBangumiChange>> getCollectChangesFromFile(
      String backupFilePath) async {
    final backupFile = File(backupFilePath);
    final backupContent = await backupFile.readAsBytes();
    final tempBox =
        await Hive.openBox('tempCollectChangesBox', bytes: backupContent);
    final tempBoxItems = tempBox.toMap().entries;
    debugPrint('webDav源变更列表长度 ${tempBoxItems.length}');

    final List<CollectedBangumiChange> collectChanges = [];
    for (var tempBoxItem in tempBoxItems) {
      collectChanges.add(tempBoxItem.value);
    }
    await tempBox.close();
    return collectChanges;
  }

  static Future<void> patchCollectibles(
      List<CollectedBangumi> remoteCollectibles,
      List<CollectedBangumiChange> remoteChanges) async {
    List<CollectedBangumi> localCollectibles = collectibles.values.toList();
    List<CollectedBangumiChange> localChanges = collectChanges.values.toList();

    final List<CollectedBangumiChange> newLocalChanges =
        localChanges.where((localChange) {
      return !remoteChanges
          .any((remoteChange) => remoteChange.id == localChange.id);
    }).toList();

    newLocalChanges.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Process local changes
    for (var change in newLocalChanges) {
      // For delete action, we don't need to look up the local collectible.
      // We can directly remove the item from the remote list.
      if (change.action == 3) {
        // Action 3: delete
        remoteCollectibles
            .removeWhere((b) => b.bangumiItem.id == change.bangumiID);
      } else {
        // For add/update, we still need to look up the local collectible.
        final changedBangumiID = change.bangumiID.toString();
        for (var localCollect in localCollectibles) {
          if (localCollect.bangumiItem.id.toString() == changedBangumiID) {
            if (change.action == 1) {
              // Action 1: add
              final exists = remoteCollectibles
                  .any((b) => b.bangumiItem.id == localCollect.bangumiItem.id);
              if (!exists) {
                remoteCollectibles.add(localCollect);
              } else {
                final index = remoteCollectibles.indexWhere(
                    (b) => b.bangumiItem.id == localCollect.bangumiItem.id);
                localCollect.type = change.type;
                if (index != -1) {
                  // Update the entry with local data.
                  remoteCollectibles[index] = localCollect;
                }
              }
            } else if (change.action == 2) {
              // Action 2: update
              final index = remoteCollectibles.indexWhere(
                  (b) => b.bangumiItem.id == localCollect.bangumiItem.id);
              localCollect.type = change.type;
              if (index != -1) {
                // Update the entry with local data.
                remoteCollectibles[index] = localCollect;
              }
            }
            break;
          }
        }
      }
    }

    // merge local changes with remote changes
    final Map<int, CollectedBangumiChange> mergedMap = {};
    for (var change in remoteChanges) {
      mergedMap[change.id] = change;
    }
    for (var change in newLocalChanges) {
      if (!mergedMap.containsKey(change.id)) {
        mergedMap[change.id] = change;
      }
    }
    final List<CollectedBangumiChange> mergedChanges =
        mergedMap.values.toList();

    // Update local storage
    await collectibles.clear();
    for (var collect in remoteCollectibles) {
      await collectibles.put(collect.bangumiItem.id, collect);
    }
    await collectChanges.clear();
    for (var change in mergedChanges) {
      await collectChanges.put(change.id, change);
    }
  }

  // Prevent instantiation
  GStorage._();

  static Future<void> _ensureRetentionDefaults() async {
    final Locale platformLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    final bool bangumiDefault = _shouldEnableBangumiByDefault(platformLocale);

    if (!setting.containsKey(SettingBoxKey.metadataRetentionHours)) {
      await setting.put(SettingBoxKey.metadataRetentionHours, 24);
    }
    if (!setting.containsKey(SettingBoxKey.downloadRetentionHours)) {
      await setting.put(SettingBoxKey.downloadRetentionHours, 24);
    }
    if (!setting.containsKey(SettingBoxKey.playbackProfileRetentionHours)) {
      await setting.put(SettingBoxKey.playbackProfileRetentionHours, 24);
    }
    if (!setting.containsKey(SettingBoxKey.metadataBangumiEnabled)) {
      await setting.put(SettingBoxKey.metadataBangumiEnabled, bangumiDefault);
    }
    if (!setting.containsKey(SettingBoxKey.metadataTmdbEnabled)) {
      await setting.put(SettingBoxKey.metadataTmdbEnabled, true);
    }
    if (!setting.containsKey(SettingBoxKey.metadataPreferredLocale)) {
      await setting.put(SettingBoxKey.metadataPreferredLocale, '');
    }
    if (!setting.containsKey(SettingBoxKey.tmdbApiKey)) {
      await setting.put(SettingBoxKey.tmdbApiKey, '');
    }
    if (!setting.containsKey(SettingBoxKey.danDanAppId)) {
      await setting.put(SettingBoxKey.danDanAppId, '');
    }
    if (!setting.containsKey(SettingBoxKey.danDanApiKey)) {
      await setting.put(SettingBoxKey.danDanApiKey, '');
    }
    if (!setting.containsKey(SettingBoxKey.aria2Endpoint)) {
      await setting.put(
          SettingBoxKey.aria2Endpoint, 'http://127.0.0.1:6800/jsonrpc');
    }
    if (!setting.containsKey(SettingBoxKey.aria2Secret)) {
      await setting.put(SettingBoxKey.aria2Secret, '');
    }
    if (!setting.containsKey(SettingBoxKey.aria2TimeoutSeconds)) {
      await setting.put(SettingBoxKey.aria2TimeoutSeconds, 15);
    }
    if (!setting.containsKey(SettingBoxKey.aria2MaxConcurrentDownloads)) {
      await setting.put(SettingBoxKey.aria2MaxConcurrentDownloads, 2);
    }
    if (!setting.containsKey(SettingBoxKey.torrentConsentAccepted)) {
      await setting.put(SettingBoxKey.torrentConsentAccepted, false);
    }
    if (!setting.containsKey(SettingBoxKey.torrentConsentTimestamp)) {
      await setting.put(SettingBoxKey.torrentConsentTimestamp, 0);
    }
  }

  static bool _shouldEnableBangumiByDefault(Locale locale) {
    final String code = locale.languageCode.toLowerCase();
    return code == 'zh' || code == 'ja';
  }

  static Duration metadataRetentionDuration() {
    return Duration(
        hours: _readRetentionHours(
      SettingBoxKey.metadataRetentionHours,
      24,
    ));
  }

  static Duration downloadRetentionDuration() {
    return Duration(
        hours: _readRetentionHours(
      SettingBoxKey.downloadRetentionHours,
      24,
    ));
  }

  static Duration playbackProfileRetentionDuration() {
    return Duration(
        hours: _readRetentionHours(
      SettingBoxKey.playbackProfileRetentionHours,
      24,
    ));
  }

  static int _readRetentionHours(String key, int fallback) {
    final dynamic value = setting.get(key, defaultValue: fallback);
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static String readDanDanAppId() {
    final String? stored =
        (setting.get(SettingBoxKey.danDanAppId, defaultValue: '') as String?)
            ?.trim();
    return (stored != null && stored.isNotEmpty)
        ? stored
        : ApiCredentials.danDanAppId;
  }

  static String readDanDanApiKey() {
    final String? stored =
        (setting.get(SettingBoxKey.danDanApiKey, defaultValue: '') as String?)
            ?.trim();
    return (stored != null && stored.isNotEmpty)
        ? stored
        : ApiCredentials.danDanApiKey;
  }
}

class SettingBoxKey {
  static const String hAenable = 'hAenable',
      hardwareDecoder = 'hardwareDecoder',
      searchEnhanceEnable = 'searchEnhanceEnable',
      autoUpdate = 'autoUpdate',
      alwaysOntop = 'alwaysOntop',
      defaultPlaySpeed = 'defaultPlaySpeed',
      defaultAspectRatioType = 'defaultAspectRatioType',
      danmakuEnhance = 'danmakuEnhance',
      danmakuBorder = 'danmakuBorder',
      danmakuOpacity = 'danmakuOpacity',
      danmakuFontSize = 'danmakuFontSize',
      danmakuTop = 'danmakuTop',
      danmakuScroll = 'danmakuScroll',
      danmakuBottom = 'danmakuBottom',
      danmakuMassive = 'danmakuMassive',
      danmakuArea = 'danmakuArea',
      danmakuColor = 'danmakuColor',
      danmakuEnabledByDefault = 'danmakuEnabledByDefault',
      danmakuBiliBiliSource = 'danmakuBiliBiliSource',
      danmakuGamerSource = 'danmakuGamerSource',
      danmakuDanDanSource = 'danmakuDanDanSource',
      danmakuFontWeight = 'danmakuFontWeight',
      themeMode = 'themeMode',
      themeColor = 'themeColor',
      privateMode = 'privateMode',
      autoPlay = 'autoPlay',
      playResume = 'playResume',
      showPlayerError = 'showPlayerError',
      oledEnhance = 'oledEnhance',
      displayMode = 'displayMode',
      enableGitProxy = 'enableGitProxy',
      enableSystemProxy = 'enableSystemProxy',
      isWideScreen = 'isWideScreen',
      webDavEnable = 'webDavEnable',
      webDavEnableHistory = 'webDavEnableHistory',
      webDavEnableCollect = 'webDavEnableCollect',
      webDavURL = 'webDavURL',
      webDavUsername = 'webDavUsername',
      webDavPassword = 'webDavPasswd',
      lowMemoryMode = 'lowMemoryMode',
      showWindowButton = 'showWindowButton',
      useDynamicColor = 'useDynamicColor',
      exitBehavior = 'exitBehavior',
      playerDebugMode = 'playerDebugMode',
      syncPlayEndPoint = 'syncPlayEndPoint',
      androidEnableOpenSLES = 'androidEnableOpenSLES',
      defaultSuperResolutionType = 'defaultSuperResolutionType',
      superResolutionWarn = 'superResolutionWarn',
      playerDisableAnimations = 'playerDisableAnimations',
      metadataRetentionHours = 'metadataRetentionHours',
      downloadRetentionHours = 'downloadRetentionHours',
      playbackProfileRetentionHours = 'playbackProfileRetentionHours',
      metadataBangumiEnabled = 'metadataBangumiEnabled',
      metadataTmdbEnabled = 'metadataTmdbEnabled',
      metadataPreferredLocale = 'metadataPreferredLocale',
      tmdbApiKey = 'tmdbApiKey',
      danDanAppId = 'danDanAppId',
      danDanApiKey = 'danDanApiKey',
      aria2Endpoint = 'aria2Endpoint',
      aria2Secret = 'aria2Secret',
      aria2TimeoutSeconds = 'aria2TimeoutSeconds',
      aria2MaxConcurrentDownloads = 'aria2MaxConcurrentDownloads',
      torrentConsentAccepted = 'torrentConsentAccepted',
      torrentConsentTimestamp = 'torrentConsentTimestamp',
      subtitleAutoMatchEnabled = 'subtitleAutoMatchEnabled',
      subtitlePreferredLanguages = 'subtitlePreferredLanguages',
      subtitlePreferredFormats = 'subtitlePreferredFormats';
}
