// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlayerState {
// 弹幕控制
// 弹幕依赖类型
  Map<int, List<Danmaku>> get danDanmakus => throw _privateConstructorUsedError;
  bool get danmakuOn => throw _privateConstructorUsedError; // 一起看控制器
  String get syncplayRoom => throw _privateConstructorUsedError;
  int get syncplayClientRtt => throw _privateConstructorUsedError;

  /// 视频比例类型
  /// 1. AUTO
  /// 2. COVER
  /// 3. FILL
  int get aspectRatioType => throw _privateConstructorUsedError;

  /// 视频超分
  /// 1. OFF
  /// 2. Anime4K
  int get superResolutionType => throw _privateConstructorUsedError; // 视频音量/亮度
  double get volume => throw _privateConstructorUsedError;
  double get brightness => throw _privateConstructorUsedError; // 播放器界面控制
  bool get lockPanel => throw _privateConstructorUsedError;
  bool get showVideoController => throw _privateConstructorUsedError;
  bool get showSeekTime => throw _privateConstructorUsedError;
  bool get showBrightness => throw _privateConstructorUsedError;
  bool get showVolume => throw _privateConstructorUsedError;
  bool get showPlaySpeed => throw _privateConstructorUsedError;
  bool get brightnessSeeking => throw _privateConstructorUsedError;
  bool get volumeSeeking => throw _privateConstructorUsedError;
  bool get canHidePlayerPanel => throw _privateConstructorUsedError; // 播放器面板状态
  bool get loading => throw _privateConstructorUsedError;
  bool get playing => throw _privateConstructorUsedError;
  bool get isBuffering => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  Duration get currentPosition => throw _privateConstructorUsedError;
  Duration get buffer => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  double get playerSpeed => throw _privateConstructorUsedError; // 播放器调试信息
  List<String> get playerLog => throw _privateConstructorUsedError;
  int get playerWidth => throw _privateConstructorUsedError;
  int get playerHeight => throw _privateConstructorUsedError;
  String get playerVideoParams => throw _privateConstructorUsedError;
  String get playerAudioParams => throw _privateConstructorUsedError;
  String get playerPlaylist => throw _privateConstructorUsedError;
  String get playerAudioTracks => throw _privateConstructorUsedError;
  String get playerVideoTracks => throw _privateConstructorUsedError;
  String get playerAudioBitrate => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PlayerStateCopyWith<PlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerStateCopyWith<$Res> {
  factory $PlayerStateCopyWith(
          PlayerState value, $Res Function(PlayerState) then) =
      _$PlayerStateCopyWithImpl<$Res, PlayerState>;
  @useResult
  $Res call(
      {Map<int, List<Danmaku>> danDanmakus,
      bool danmakuOn,
      String syncplayRoom,
      int syncplayClientRtt,
      int aspectRatioType,
      int superResolutionType,
      double volume,
      double brightness,
      bool lockPanel,
      bool showVideoController,
      bool showSeekTime,
      bool showBrightness,
      bool showVolume,
      bool showPlaySpeed,
      bool brightnessSeeking,
      bool volumeSeeking,
      bool canHidePlayerPanel,
      bool loading,
      bool playing,
      bool isBuffering,
      bool completed,
      Duration currentPosition,
      Duration buffer,
      Duration duration,
      double playerSpeed,
      List<String> playerLog,
      int playerWidth,
      int playerHeight,
      String playerVideoParams,
      String playerAudioParams,
      String playerPlaylist,
      String playerAudioTracks,
      String playerVideoTracks,
      String playerAudioBitrate});
}

/// @nodoc
class _$PlayerStateCopyWithImpl<$Res, $Val extends PlayerState>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? danDanmakus = null,
    Object? danmakuOn = null,
    Object? syncplayRoom = null,
    Object? syncplayClientRtt = null,
    Object? aspectRatioType = null,
    Object? superResolutionType = null,
    Object? volume = null,
    Object? brightness = null,
    Object? lockPanel = null,
    Object? showVideoController = null,
    Object? showSeekTime = null,
    Object? showBrightness = null,
    Object? showVolume = null,
    Object? showPlaySpeed = null,
    Object? brightnessSeeking = null,
    Object? volumeSeeking = null,
    Object? canHidePlayerPanel = null,
    Object? loading = null,
    Object? playing = null,
    Object? isBuffering = null,
    Object? completed = null,
    Object? currentPosition = null,
    Object? buffer = null,
    Object? duration = null,
    Object? playerSpeed = null,
    Object? playerLog = null,
    Object? playerWidth = null,
    Object? playerHeight = null,
    Object? playerVideoParams = null,
    Object? playerAudioParams = null,
    Object? playerPlaylist = null,
    Object? playerAudioTracks = null,
    Object? playerVideoTracks = null,
    Object? playerAudioBitrate = null,
  }) {
    return _then(_value.copyWith(
      danDanmakus: null == danDanmakus
          ? _value.danDanmakus
          : danDanmakus // ignore: cast_nullable_to_non_nullable
              as Map<int, List<Danmaku>>,
      danmakuOn: null == danmakuOn
          ? _value.danmakuOn
          : danmakuOn // ignore: cast_nullable_to_non_nullable
              as bool,
      syncplayRoom: null == syncplayRoom
          ? _value.syncplayRoom
          : syncplayRoom // ignore: cast_nullable_to_non_nullable
              as String,
      syncplayClientRtt: null == syncplayClientRtt
          ? _value.syncplayClientRtt
          : syncplayClientRtt // ignore: cast_nullable_to_non_nullable
              as int,
      aspectRatioType: null == aspectRatioType
          ? _value.aspectRatioType
          : aspectRatioType // ignore: cast_nullable_to_non_nullable
              as int,
      superResolutionType: null == superResolutionType
          ? _value.superResolutionType
          : superResolutionType // ignore: cast_nullable_to_non_nullable
              as int,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      brightness: null == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as double,
      lockPanel: null == lockPanel
          ? _value.lockPanel
          : lockPanel // ignore: cast_nullable_to_non_nullable
              as bool,
      showVideoController: null == showVideoController
          ? _value.showVideoController
          : showVideoController // ignore: cast_nullable_to_non_nullable
              as bool,
      showSeekTime: null == showSeekTime
          ? _value.showSeekTime
          : showSeekTime // ignore: cast_nullable_to_non_nullable
              as bool,
      showBrightness: null == showBrightness
          ? _value.showBrightness
          : showBrightness // ignore: cast_nullable_to_non_nullable
              as bool,
      showVolume: null == showVolume
          ? _value.showVolume
          : showVolume // ignore: cast_nullable_to_non_nullable
              as bool,
      showPlaySpeed: null == showPlaySpeed
          ? _value.showPlaySpeed
          : showPlaySpeed // ignore: cast_nullable_to_non_nullable
              as bool,
      brightnessSeeking: null == brightnessSeeking
          ? _value.brightnessSeeking
          : brightnessSeeking // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeSeeking: null == volumeSeeking
          ? _value.volumeSeeking
          : volumeSeeking // ignore: cast_nullable_to_non_nullable
              as bool,
      canHidePlayerPanel: null == canHidePlayerPanel
          ? _value.canHidePlayerPanel
          : canHidePlayerPanel // ignore: cast_nullable_to_non_nullable
              as bool,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as bool,
      isBuffering: null == isBuffering
          ? _value.isBuffering
          : isBuffering // ignore: cast_nullable_to_non_nullable
              as bool,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPosition: null == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Duration,
      buffer: null == buffer
          ? _value.buffer
          : buffer // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      playerSpeed: null == playerSpeed
          ? _value.playerSpeed
          : playerSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      playerLog: null == playerLog
          ? _value.playerLog
          : playerLog // ignore: cast_nullable_to_non_nullable
              as List<String>,
      playerWidth: null == playerWidth
          ? _value.playerWidth
          : playerWidth // ignore: cast_nullable_to_non_nullable
              as int,
      playerHeight: null == playerHeight
          ? _value.playerHeight
          : playerHeight // ignore: cast_nullable_to_non_nullable
              as int,
      playerVideoParams: null == playerVideoParams
          ? _value.playerVideoParams
          : playerVideoParams // ignore: cast_nullable_to_non_nullable
              as String,
      playerAudioParams: null == playerAudioParams
          ? _value.playerAudioParams
          : playerAudioParams // ignore: cast_nullable_to_non_nullable
              as String,
      playerPlaylist: null == playerPlaylist
          ? _value.playerPlaylist
          : playerPlaylist // ignore: cast_nullable_to_non_nullable
              as String,
      playerAudioTracks: null == playerAudioTracks
          ? _value.playerAudioTracks
          : playerAudioTracks // ignore: cast_nullable_to_non_nullable
              as String,
      playerVideoTracks: null == playerVideoTracks
          ? _value.playerVideoTracks
          : playerVideoTracks // ignore: cast_nullable_to_non_nullable
              as String,
      playerAudioBitrate: null == playerAudioBitrate
          ? _value.playerAudioBitrate
          : playerAudioBitrate // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerStateImplCopyWith<$Res>
    implements $PlayerStateCopyWith<$Res> {
  factory _$$PlayerStateImplCopyWith(
          _$PlayerStateImpl value, $Res Function(_$PlayerStateImpl) then) =
      __$$PlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<int, List<Danmaku>> danDanmakus,
      bool danmakuOn,
      String syncplayRoom,
      int syncplayClientRtt,
      int aspectRatioType,
      int superResolutionType,
      double volume,
      double brightness,
      bool lockPanel,
      bool showVideoController,
      bool showSeekTime,
      bool showBrightness,
      bool showVolume,
      bool showPlaySpeed,
      bool brightnessSeeking,
      bool volumeSeeking,
      bool canHidePlayerPanel,
      bool loading,
      bool playing,
      bool isBuffering,
      bool completed,
      Duration currentPosition,
      Duration buffer,
      Duration duration,
      double playerSpeed,
      List<String> playerLog,
      int playerWidth,
      int playerHeight,
      String playerVideoParams,
      String playerAudioParams,
      String playerPlaylist,
      String playerAudioTracks,
      String playerVideoTracks,
      String playerAudioBitrate});
}

/// @nodoc
class __$$PlayerStateImplCopyWithImpl<$Res>
    extends _$PlayerStateCopyWithImpl<$Res, _$PlayerStateImpl>
    implements _$$PlayerStateImplCopyWith<$Res> {
  __$$PlayerStateImplCopyWithImpl(
      _$PlayerStateImpl _value, $Res Function(_$PlayerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? danDanmakus = null,
    Object? danmakuOn = null,
    Object? syncplayRoom = null,
    Object? syncplayClientRtt = null,
    Object? aspectRatioType = null,
    Object? superResolutionType = null,
    Object? volume = null,
    Object? brightness = null,
    Object? lockPanel = null,
    Object? showVideoController = null,
    Object? showSeekTime = null,
    Object? showBrightness = null,
    Object? showVolume = null,
    Object? showPlaySpeed = null,
    Object? brightnessSeeking = null,
    Object? volumeSeeking = null,
    Object? canHidePlayerPanel = null,
    Object? loading = null,
    Object? playing = null,
    Object? isBuffering = null,
    Object? completed = null,
    Object? currentPosition = null,
    Object? buffer = null,
    Object? duration = null,
    Object? playerSpeed = null,
    Object? playerLog = null,
    Object? playerWidth = null,
    Object? playerHeight = null,
    Object? playerVideoParams = null,
    Object? playerAudioParams = null,
    Object? playerPlaylist = null,
    Object? playerAudioTracks = null,
    Object? playerVideoTracks = null,
    Object? playerAudioBitrate = null,
  }) {
    return _then(_$PlayerStateImpl(
      danDanmakus: null == danDanmakus
          ? _value._danDanmakus
          : danDanmakus // ignore: cast_nullable_to_non_nullable
              as Map<int, List<Danmaku>>,
      danmakuOn: null == danmakuOn
          ? _value.danmakuOn
          : danmakuOn // ignore: cast_nullable_to_non_nullable
              as bool,
      syncplayRoom: null == syncplayRoom
          ? _value.syncplayRoom
          : syncplayRoom // ignore: cast_nullable_to_non_nullable
              as String,
      syncplayClientRtt: null == syncplayClientRtt
          ? _value.syncplayClientRtt
          : syncplayClientRtt // ignore: cast_nullable_to_non_nullable
              as int,
      aspectRatioType: null == aspectRatioType
          ? _value.aspectRatioType
          : aspectRatioType // ignore: cast_nullable_to_non_nullable
              as int,
      superResolutionType: null == superResolutionType
          ? _value.superResolutionType
          : superResolutionType // ignore: cast_nullable_to_non_nullable
              as int,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      brightness: null == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as double,
      lockPanel: null == lockPanel
          ? _value.lockPanel
          : lockPanel // ignore: cast_nullable_to_non_nullable
              as bool,
      showVideoController: null == showVideoController
          ? _value.showVideoController
          : showVideoController // ignore: cast_nullable_to_non_nullable
              as bool,
      showSeekTime: null == showSeekTime
          ? _value.showSeekTime
          : showSeekTime // ignore: cast_nullable_to_non_nullable
              as bool,
      showBrightness: null == showBrightness
          ? _value.showBrightness
          : showBrightness // ignore: cast_nullable_to_non_nullable
              as bool,
      showVolume: null == showVolume
          ? _value.showVolume
          : showVolume // ignore: cast_nullable_to_non_nullable
              as bool,
      showPlaySpeed: null == showPlaySpeed
          ? _value.showPlaySpeed
          : showPlaySpeed // ignore: cast_nullable_to_non_nullable
              as bool,
      brightnessSeeking: null == brightnessSeeking
          ? _value.brightnessSeeking
          : brightnessSeeking // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeSeeking: null == volumeSeeking
          ? _value.volumeSeeking
          : volumeSeeking // ignore: cast_nullable_to_non_nullable
              as bool,
      canHidePlayerPanel: null == canHidePlayerPanel
          ? _value.canHidePlayerPanel
          : canHidePlayerPanel // ignore: cast_nullable_to_non_nullable
              as bool,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as bool,
      isBuffering: null == isBuffering
          ? _value.isBuffering
          : isBuffering // ignore: cast_nullable_to_non_nullable
              as bool,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPosition: null == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Duration,
      buffer: null == buffer
          ? _value.buffer
          : buffer // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      playerSpeed: null == playerSpeed
          ? _value.playerSpeed
          : playerSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      playerLog: null == playerLog
          ? _value._playerLog
          : playerLog // ignore: cast_nullable_to_non_nullable
              as List<String>,
      playerWidth: null == playerWidth
          ? _value.playerWidth
          : playerWidth // ignore: cast_nullable_to_non_nullable
              as int,
      playerHeight: null == playerHeight
          ? _value.playerHeight
          : playerHeight // ignore: cast_nullable_to_non_nullable
              as int,
      playerVideoParams: null == playerVideoParams
          ? _value.playerVideoParams
          : playerVideoParams // ignore: cast_nullable_to_non_nullable
              as String,
      playerAudioParams: null == playerAudioParams
          ? _value.playerAudioParams
          : playerAudioParams // ignore: cast_nullable_to_non_nullable
              as String,
      playerPlaylist: null == playerPlaylist
          ? _value.playerPlaylist
          : playerPlaylist // ignore: cast_nullable_to_non_nullable
              as String,
      playerAudioTracks: null == playerAudioTracks
          ? _value.playerAudioTracks
          : playerAudioTracks // ignore: cast_nullable_to_non_nullable
              as String,
      playerVideoTracks: null == playerVideoTracks
          ? _value.playerVideoTracks
          : playerVideoTracks // ignore: cast_nullable_to_non_nullable
              as String,
      playerAudioBitrate: null == playerAudioBitrate
          ? _value.playerAudioBitrate
          : playerAudioBitrate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PlayerStateImpl implements _PlayerState {
  const _$PlayerStateImpl(
      {final Map<int, List<Danmaku>> danDanmakus = const {},
      this.danmakuOn = false,
      this.syncplayRoom = '',
      this.syncplayClientRtt = 0,
      this.aspectRatioType = 1,
      this.superResolutionType = 1,
      this.volume = -1,
      this.brightness = 0,
      this.lockPanel = false,
      this.showVideoController = true,
      this.showSeekTime = false,
      this.showBrightness = false,
      this.showVolume = false,
      this.showPlaySpeed = false,
      this.brightnessSeeking = false,
      this.volumeSeeking = false,
      this.canHidePlayerPanel = true,
      this.loading = true,
      this.playing = false,
      this.isBuffering = true,
      this.completed = false,
      this.currentPosition = Duration.zero,
      this.buffer = Duration.zero,
      this.duration = Duration.zero,
      this.playerSpeed = 1.0,
      final List<String> playerLog = const [],
      this.playerWidth = 0,
      this.playerHeight = 0,
      this.playerVideoParams = '',
      this.playerAudioParams = '',
      this.playerPlaylist = '',
      this.playerAudioTracks = '',
      this.playerVideoTracks = '',
      this.playerAudioBitrate = ''})
      : _danDanmakus = danDanmakus,
        _playerLog = playerLog;

// 弹幕控制
// 弹幕依赖类型
  final Map<int, List<Danmaku>> _danDanmakus;
// 弹幕控制
// 弹幕依赖类型
  @override
  @JsonKey()
  Map<int, List<Danmaku>> get danDanmakus {
    if (_danDanmakus is EqualUnmodifiableMapView) return _danDanmakus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_danDanmakus);
  }

  @override
  @JsonKey()
  final bool danmakuOn;
// 一起看控制器
  @override
  @JsonKey()
  final String syncplayRoom;
  @override
  @JsonKey()
  final int syncplayClientRtt;

  /// 视频比例类型
  /// 1. AUTO
  /// 2. COVER
  /// 3. FILL
  @override
  @JsonKey()
  final int aspectRatioType;

  /// 视频超分
  /// 1. OFF
  /// 2. Anime4K
  @override
  @JsonKey()
  final int superResolutionType;
// 视频音量/亮度
  @override
  @JsonKey()
  final double volume;
  @override
  @JsonKey()
  final double brightness;
// 播放器界面控制
  @override
  @JsonKey()
  final bool lockPanel;
  @override
  @JsonKey()
  final bool showVideoController;
  @override
  @JsonKey()
  final bool showSeekTime;
  @override
  @JsonKey()
  final bool showBrightness;
  @override
  @JsonKey()
  final bool showVolume;
  @override
  @JsonKey()
  final bool showPlaySpeed;
  @override
  @JsonKey()
  final bool brightnessSeeking;
  @override
  @JsonKey()
  final bool volumeSeeking;
  @override
  @JsonKey()
  final bool canHidePlayerPanel;
// 播放器面板状态
  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool playing;
  @override
  @JsonKey()
  final bool isBuffering;
  @override
  @JsonKey()
  final bool completed;
  @override
  @JsonKey()
  final Duration currentPosition;
  @override
  @JsonKey()
  final Duration buffer;
  @override
  @JsonKey()
  final Duration duration;
  @override
  @JsonKey()
  final double playerSpeed;
// 播放器调试信息
  final List<String> _playerLog;
// 播放器调试信息
  @override
  @JsonKey()
  List<String> get playerLog {
    if (_playerLog is EqualUnmodifiableListView) return _playerLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerLog);
  }

  @override
  @JsonKey()
  final int playerWidth;
  @override
  @JsonKey()
  final int playerHeight;
  @override
  @JsonKey()
  final String playerVideoParams;
  @override
  @JsonKey()
  final String playerAudioParams;
  @override
  @JsonKey()
  final String playerPlaylist;
  @override
  @JsonKey()
  final String playerAudioTracks;
  @override
  @JsonKey()
  final String playerVideoTracks;
  @override
  @JsonKey()
  final String playerAudioBitrate;

  @override
  String toString() {
    return 'PlayerState(danDanmakus: $danDanmakus, danmakuOn: $danmakuOn, syncplayRoom: $syncplayRoom, syncplayClientRtt: $syncplayClientRtt, aspectRatioType: $aspectRatioType, superResolutionType: $superResolutionType, volume: $volume, brightness: $brightness, lockPanel: $lockPanel, showVideoController: $showVideoController, showSeekTime: $showSeekTime, showBrightness: $showBrightness, showVolume: $showVolume, showPlaySpeed: $showPlaySpeed, brightnessSeeking: $brightnessSeeking, volumeSeeking: $volumeSeeking, canHidePlayerPanel: $canHidePlayerPanel, loading: $loading, playing: $playing, isBuffering: $isBuffering, completed: $completed, currentPosition: $currentPosition, buffer: $buffer, duration: $duration, playerSpeed: $playerSpeed, playerLog: $playerLog, playerWidth: $playerWidth, playerHeight: $playerHeight, playerVideoParams: $playerVideoParams, playerAudioParams: $playerAudioParams, playerPlaylist: $playerPlaylist, playerAudioTracks: $playerAudioTracks, playerVideoTracks: $playerVideoTracks, playerAudioBitrate: $playerAudioBitrate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerStateImpl &&
            const DeepCollectionEquality()
                .equals(other._danDanmakus, _danDanmakus) &&
            (identical(other.danmakuOn, danmakuOn) ||
                other.danmakuOn == danmakuOn) &&
            (identical(other.syncplayRoom, syncplayRoom) ||
                other.syncplayRoom == syncplayRoom) &&
            (identical(other.syncplayClientRtt, syncplayClientRtt) ||
                other.syncplayClientRtt == syncplayClientRtt) &&
            (identical(other.aspectRatioType, aspectRatioType) ||
                other.aspectRatioType == aspectRatioType) &&
            (identical(other.superResolutionType, superResolutionType) ||
                other.superResolutionType == superResolutionType) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.brightness, brightness) ||
                other.brightness == brightness) &&
            (identical(other.lockPanel, lockPanel) ||
                other.lockPanel == lockPanel) &&
            (identical(other.showVideoController, showVideoController) ||
                other.showVideoController == showVideoController) &&
            (identical(other.showSeekTime, showSeekTime) ||
                other.showSeekTime == showSeekTime) &&
            (identical(other.showBrightness, showBrightness) ||
                other.showBrightness == showBrightness) &&
            (identical(other.showVolume, showVolume) ||
                other.showVolume == showVolume) &&
            (identical(other.showPlaySpeed, showPlaySpeed) ||
                other.showPlaySpeed == showPlaySpeed) &&
            (identical(other.brightnessSeeking, brightnessSeeking) ||
                other.brightnessSeeking == brightnessSeeking) &&
            (identical(other.volumeSeeking, volumeSeeking) ||
                other.volumeSeeking == volumeSeeking) &&
            (identical(other.canHidePlayerPanel, canHidePlayerPanel) ||
                other.canHidePlayerPanel == canHidePlayerPanel) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.playing, playing) || other.playing == playing) &&
            (identical(other.isBuffering, isBuffering) ||
                other.isBuffering == isBuffering) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition) &&
            (identical(other.buffer, buffer) || other.buffer == buffer) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.playerSpeed, playerSpeed) ||
                other.playerSpeed == playerSpeed) &&
            const DeepCollectionEquality()
                .equals(other._playerLog, _playerLog) &&
            (identical(other.playerWidth, playerWidth) ||
                other.playerWidth == playerWidth) &&
            (identical(other.playerHeight, playerHeight) ||
                other.playerHeight == playerHeight) &&
            (identical(other.playerVideoParams, playerVideoParams) ||
                other.playerVideoParams == playerVideoParams) &&
            (identical(other.playerAudioParams, playerAudioParams) ||
                other.playerAudioParams == playerAudioParams) &&
            (identical(other.playerPlaylist, playerPlaylist) ||
                other.playerPlaylist == playerPlaylist) &&
            (identical(other.playerAudioTracks, playerAudioTracks) ||
                other.playerAudioTracks == playerAudioTracks) &&
            (identical(other.playerVideoTracks, playerVideoTracks) ||
                other.playerVideoTracks == playerVideoTracks) &&
            (identical(other.playerAudioBitrate, playerAudioBitrate) ||
                other.playerAudioBitrate == playerAudioBitrate));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_danDanmakus),
        danmakuOn,
        syncplayRoom,
        syncplayClientRtt,
        aspectRatioType,
        superResolutionType,
        volume,
        brightness,
        lockPanel,
        showVideoController,
        showSeekTime,
        showBrightness,
        showVolume,
        showPlaySpeed,
        brightnessSeeking,
        volumeSeeking,
        canHidePlayerPanel,
        loading,
        playing,
        isBuffering,
        completed,
        currentPosition,
        buffer,
        duration,
        playerSpeed,
        const DeepCollectionEquality().hash(_playerLog),
        playerWidth,
        playerHeight,
        playerVideoParams,
        playerAudioParams,
        playerPlaylist,
        playerAudioTracks,
        playerVideoTracks,
        playerAudioBitrate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      __$$PlayerStateImplCopyWithImpl<_$PlayerStateImpl>(this, _$identity);
}

abstract class _PlayerState implements PlayerState {
  const factory _PlayerState(
      {final Map<int, List<Danmaku>> danDanmakus,
      final bool danmakuOn,
      final String syncplayRoom,
      final int syncplayClientRtt,
      final int aspectRatioType,
      final int superResolutionType,
      final double volume,
      final double brightness,
      final bool lockPanel,
      final bool showVideoController,
      final bool showSeekTime,
      final bool showBrightness,
      final bool showVolume,
      final bool showPlaySpeed,
      final bool brightnessSeeking,
      final bool volumeSeeking,
      final bool canHidePlayerPanel,
      final bool loading,
      final bool playing,
      final bool isBuffering,
      final bool completed,
      final Duration currentPosition,
      final Duration buffer,
      final Duration duration,
      final double playerSpeed,
      final List<String> playerLog,
      final int playerWidth,
      final int playerHeight,
      final String playerVideoParams,
      final String playerAudioParams,
      final String playerPlaylist,
      final String playerAudioTracks,
      final String playerVideoTracks,
      final String playerAudioBitrate}) = _$PlayerStateImpl;

  @override // 弹幕控制
// 弹幕依赖类型
  Map<int, List<Danmaku>> get danDanmakus;
  @override
  bool get danmakuOn;
  @override // 一起看控制器
  String get syncplayRoom;
  @override
  int get syncplayClientRtt;
  @override

  /// 视频比例类型
  /// 1. AUTO
  /// 2. COVER
  /// 3. FILL
  int get aspectRatioType;
  @override

  /// 视频超分
  /// 1. OFF
  /// 2. Anime4K
  int get superResolutionType;
  @override // 视频音量/亮度
  double get volume;
  @override
  double get brightness;
  @override // 播放器界面控制
  bool get lockPanel;
  @override
  bool get showVideoController;
  @override
  bool get showSeekTime;
  @override
  bool get showBrightness;
  @override
  bool get showVolume;
  @override
  bool get showPlaySpeed;
  @override
  bool get brightnessSeeking;
  @override
  bool get volumeSeeking;
  @override
  bool get canHidePlayerPanel;
  @override // 播放器面板状态
  bool get loading;
  @override
  bool get playing;
  @override
  bool get isBuffering;
  @override
  bool get completed;
  @override
  Duration get currentPosition;
  @override
  Duration get buffer;
  @override
  Duration get duration;
  @override
  double get playerSpeed;
  @override // 播放器调试信息
  List<String> get playerLog;
  @override
  int get playerWidth;
  @override
  int get playerHeight;
  @override
  String get playerVideoParams;
  @override
  String get playerAudioParams;
  @override
  String get playerPlaylist;
  @override
  String get playerAudioTracks;
  @override
  String get playerVideoTracks;
  @override
  String get playerAudioBitrate;
  @override
  @JsonKey(ignore: true)
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
