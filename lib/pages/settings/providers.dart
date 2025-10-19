import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/safe_state_notifier.dart';

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

class ThemeNotifier extends SafeStateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

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

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

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
      defaultAspectRatioType: defaultAspectRatioType ?? this.defaultAspectRatioType,
      hAenable: hAenable ?? this.hAenable,
      androidEnableOpenSLES: androidEnableOpenSLES ?? this.androidEnableOpenSLES,
      lowMemoryMode: lowMemoryMode ?? this.lowMemoryMode,
      playResume: playResume ?? this.playResume,
      showPlayerError: showPlayerError ?? this.showPlayerError,
      privateMode: privateMode ?? this.privateMode,
      playerDebugMode: playerDebugMode ?? this.playerDebugMode,
      playerDisableAnimations: playerDisableAnimations ?? this.playerDisableAnimations,
    );
  }
}

class PlayerSettingsNotifier extends SafeStateNotifier<PlayerSettingsState> {
  PlayerSettingsNotifier() : super(const PlayerSettingsState());

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

final playerSettingsProvider = StateNotifierProvider<PlayerSettingsNotifier, PlayerSettingsState>(
  (ref) => PlayerSettingsNotifier(),
);
