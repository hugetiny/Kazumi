import 'package:kazumi/modules/danmaku/danmaku_module.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
  // 弹幕控制
    // 弹幕依赖类型
    @Default({}) Map<int, List<Danmaku>> danDanmakus,
    @Default(false) bool danmakuOn,

    // 一起看控制器
    @Default('') String syncplayRoom,
    @Default(0) int syncplayClientRtt,

    /// 视频比例类型
    /// 1. AUTO
    /// 2. COVER
    /// 3. FILL
    @Default(1) int aspectRatioType,

    /// 视频超分
    /// 1. OFF
    /// 2. Anime4K
    @Default(1) int superResolutionType,

    // 视频音量/亮度
    @Default(-1) double volume,
    @Default(0) double brightness,

    // 播放器界面控制
    @Default(false) bool lockPanel,
    @Default(true) bool showVideoController,
    @Default(false) bool showSeekTime,
    @Default(false) bool showBrightness,
    @Default(false) bool showVolume,
    @Default(false) bool showPlaySpeed,
    @Default(false) bool brightnessSeeking,
    @Default(false) bool volumeSeeking,
    @Default(true) bool canHidePlayerPanel,

    // 播放器面板状态
    @Default(true) bool loading,
    @Default(false) bool playing,
    @Default(true) bool isBuffering,
    @Default(false) bool completed,
    @Default(Duration.zero) Duration currentPosition,
    @Default(Duration.zero) Duration buffer,
    @Default(Duration.zero) Duration duration,
    @Default(1.0) double playerSpeed,

    // 播放器调试信息
    @Default([]) List<String> playerLog,
    @Default(0) int playerWidth,
    @Default(0) int playerHeight,
    @Default('') String playerVideoParams,
    @Default('') String playerAudioParams,
    @Default('') String playerPlaylist,
    @Default('') String playerAudioTracks,
    @Default('') String playerVideoTracks,
    @Default('') String playerAudioBitrate,
  }) = _PlayerState;
}