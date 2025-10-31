import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool useDynamicColor;
  final Color seedColor;
  final bool oledEnhance;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.useDynamicColor = false,
    this.seedColor = Colors.green,
    this.oledEnhance = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? useDynamicColor,
    Color? seedColor,
    bool? oledEnhance,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      seedColor: seedColor ?? this.seedColor,
      oledEnhance: oledEnhance ?? this.oledEnhance,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() => const ThemeState();

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setUseDynamicColor(bool useDynamicColor) {
    state = state.copyWith(useDynamicColor: useDynamicColor);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
  }

  void setOledEnhance(bool value) {
    state = state.copyWith(oledEnhance: value);
  }
}

final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

class PlayerSettingsState {
  final double defaultPlaySpeed;
  final int defaultAspectRatioType;
  final bool hAenable;
  final bool androidEnableOpenSLES;
  final bool lowMemoryMode;
  final bool playResume;
  final bool showPlayerError;
  final bool privateMode;
  final bool playerDebugMode;
  final bool playerDisableAnimations;

  const PlayerSettingsState({
    this.defaultPlaySpeed = 1.0,
    this.defaultAspectRatioType = 1,
    this.hAenable = true,
    this.androidEnableOpenSLES = true,
    this.lowMemoryMode = false,
    this.playResume = true,
    this.showPlayerError = true,
    this.privateMode = false,
    this.playerDebugMode = false,
    this.playerDisableAnimations = false,
  });

  PlayerSettingsState copyWith({
    double? defaultPlaySpeed,
    int? defaultAspectRatioType,
    bool? hAenable,
    bool? androidEnableOpenSLES,
    bool? lowMemoryMode,
    bool? playResume,
    bool? showPlayerError,
    bool? privateMode,
    bool? playerDebugMode,
    bool? playerDisableAnimations,
  }) {
    return PlayerSettingsState(
      defaultPlaySpeed: defaultPlaySpeed ?? this.defaultPlaySpeed,
      defaultAspectRatioType:
          defaultAspectRatioType ?? this.defaultAspectRatioType,
      hAenable: hAenable ?? this.hAenable,
      androidEnableOpenSLES:
          androidEnableOpenSLES ?? this.androidEnableOpenSLES,
      lowMemoryMode: lowMemoryMode ?? this.lowMemoryMode,
      playResume: playResume ?? this.playResume,
      showPlayerError: showPlayerError ?? this.showPlayerError,
      privateMode: privateMode ?? this.privateMode,
      playerDebugMode: playerDebugMode ?? this.playerDebugMode,
      playerDisableAnimations:
          playerDisableAnimations ?? this.playerDisableAnimations,
    );
  }
}

class PlayerSettingsNotifier extends Notifier<PlayerSettingsState> {
  @override
  PlayerSettingsState build() => const PlayerSettingsState();

  bool _initialized = false;

  void initialize(PlayerSettingsState initialState) {
    if (_initialized) return;
    state = initialState;
    _initialized = true;
  }

  void setDefaultPlaySpeed(double speed) {
    state = state.copyWith(defaultPlaySpeed: speed);
  }

  void setDefaultAspectRatioType(int type) {
    state = state.copyWith(defaultAspectRatioType: type);
  }

  void setHAEnable(bool value) {
    state = state.copyWith(hAenable: value);
  }

  void setAndroidEnableOpenSLES(bool value) {
    state = state.copyWith(androidEnableOpenSLES: value);
  }

  void setLowMemoryMode(bool value) {
    state = state.copyWith(lowMemoryMode: value);
  }

  void setPlayResume(bool value) {
    state = state.copyWith(playResume: value);
  }

  void setShowPlayerError(bool value) {
    state = state.copyWith(showPlayerError: value);
  }

  void setPrivateMode(bool value) {
    state = state.copyWith(privateMode: value);
  }

  void setPlayerDebugMode(bool value) {
    state = state.copyWith(playerDebugMode: value);
  }

  void setPlayerDisableAnimations(bool value) {
    state = state.copyWith(playerDisableAnimations: value);
  }
}

final playerSettingsProvider =
    NotifierProvider<PlayerSettingsNotifier, PlayerSettingsState>(
  PlayerSettingsNotifier.new,
);

class _ManualLocaleSentinel {
  const _ManualLocaleSentinel();
}

class MetadataSettingsState {
  const MetadataSettingsState({
    required this.bangumiEnabled,
    required this.tmdbEnabled,
    required this.manualLocaleTag,
  });

  final bool bangumiEnabled;
  final bool tmdbEnabled;
  final String? manualLocaleTag;

  bool get followSystemLocale => manualLocaleTag == null;

  static const _ManualLocaleSentinel _manualLocaleSentinel =
      _ManualLocaleSentinel();

  MetadataSettingsState copyWith({
    bool? bangumiEnabled,
    bool? tmdbEnabled,
    Object? manualLocaleTag = _manualLocaleSentinel,
  }) {
    return MetadataSettingsState(
      bangumiEnabled: bangumiEnabled ?? this.bangumiEnabled,
      tmdbEnabled: tmdbEnabled ?? this.tmdbEnabled,
      manualLocaleTag: manualLocaleTag == _manualLocaleSentinel
          ? this.manualLocaleTag
          : manualLocaleTag as String?,
    );
  }
}

class MetadataSettingsNotifier extends Notifier<MetadataSettingsState> {
  @override
  MetadataSettingsState build() {
    final bool bangumiEnabled = GStorage.setting.get(
          SettingBoxKey.metadataBangumiEnabled,
          defaultValue: true,
        ) as bool? ??
        true;
    final bool tmdbEnabled = GStorage.setting.get(
          SettingBoxKey.metadataTmdbEnabled,
          defaultValue: true,
        ) as bool? ??
        true;
    final String? rawLocaleTag = GStorage.setting.get(
          SettingBoxKey.metadataPreferredLocale,
          defaultValue: '',
        ) as String?;
    final String? manualLocaleTag =
        (rawLocaleTag == null || rawLocaleTag.isEmpty) ? null : rawLocaleTag;
    return MetadataSettingsState(
      bangumiEnabled: bangumiEnabled,
      tmdbEnabled: tmdbEnabled,
      manualLocaleTag: manualLocaleTag,
    );
  }

  Future<void> setBangumiEnabled(bool value) async {
    await GStorage.setting.put(SettingBoxKey.metadataBangumiEnabled, value);
    state = state.copyWith(bangumiEnabled: value);
  }

  Future<void> setTmdbEnabled(bool value) async {
    await GStorage.setting.put(SettingBoxKey.metadataTmdbEnabled, value);
    state = state.copyWith(tmdbEnabled: value);
  }

  Future<void> setManualLocale(String? localeTag) async {
    final String storedValue = localeTag?.trim() ?? '';
    await GStorage.setting.put(
      SettingBoxKey.metadataPreferredLocale,
      storedValue,
    );
    state = state.copyWith(
      manualLocaleTag: storedValue.isEmpty ? null : storedValue,
    );
  }
}

final metadataSettingsProvider =
    NotifierProvider<MetadataSettingsNotifier, MetadataSettingsState>(
  MetadataSettingsNotifier.new,
);

// App Locale Settings Provider
class LocaleSettingsState {
  const LocaleSettingsState({
    required this.appLocale,
    required this.followSystem,
  });

  final AppLocale appLocale;
  final bool followSystem;

  LocaleSettingsState copyWith({
    AppLocale? appLocale,
    bool? followSystem,
  }) {
    return LocaleSettingsState(
      appLocale: appLocale ?? this.appLocale,
      followSystem: followSystem ?? this.followSystem,
    );
  }
}

class LocaleSettingsNotifier extends Notifier<LocaleSettingsState> {
  @override
  LocaleSettingsState build() {
    final String? savedLocale = GStorage.setting.get(
      SettingBoxKey.appLocale,
      defaultValue: '',
    ) as String?;

    final bool followSystem = savedLocale == null || savedLocale.isEmpty;
    final AppLocale initialLocale = _resolveAppLocale(
      savedLocale,
      followSystem: followSystem,
    );

    return LocaleSettingsState(
      appLocale: initialLocale,
      followSystem: followSystem,
    );
  }

  Future<void> setLocale(AppLocale locale) async {
    await GStorage.setting.put(SettingBoxKey.appLocale, locale.languageTag);
    LocaleSettings.setLocale(locale);
    state = state.copyWith(
      appLocale: locale,
      followSystem: false,
    );
  }

  Future<void> useSystemLocale() async {
    await GStorage.setting.put(SettingBoxKey.appLocale, '');
    final AppLocale deviceLocale = AppLocaleUtils.findDeviceLocale();
    LocaleSettings.useDeviceLocale();
    state = state.copyWith(
      appLocale: deviceLocale,
      followSystem: true,
    );
  }

  AppLocale _resolveAppLocale(
    String? savedLocaleTag, {
    required bool followSystem,
  }) {
    if (!followSystem) {
      try {
        return AppLocaleUtils.parse(savedLocaleTag!);
      } catch (_) {
        // Fallback to device locale if parsing fails.
      }
    }
    return AppLocaleUtils.findDeviceLocale();
  }
}

final localeSettingsProvider =
    NotifierProvider<LocaleSettingsNotifier, LocaleSettingsState>(
  LocaleSettingsNotifier.new,
);
