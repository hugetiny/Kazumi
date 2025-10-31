﻿import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kazumi/bean/appbar/drag_to_move_bar.dart' as dtb;
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/widget/collect_button.dart';
import 'package:kazumi/bean/widget/embedded_native_control_area.dart';
import 'package:kazumi/pages/player/player_controller.dart';
import 'package:kazumi/pages/player/player_providers.dart';
import 'package:kazumi/pages/player/player_state.dart';
import 'package:kazumi/pages/settings/danmaku/danmaku_settings_sheet.dart';
import 'package:kazumi/pages/video/providers.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/video/video_state.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/remote.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class SmallestPlayerItemPanel extends ConsumerStatefulWidget {
  const SmallestPlayerItemPanel({
    super.key,
    required this.onBackPressed,
    required this.setPlaybackSpeed,
    required this.showDanmakuSwitch,
    required this.handleFullscreen,
    required this.handleProgressBarDragStart,
    required this.handleProgressBarDragEnd,
    required this.handleSuperResolutionChange,
    required this.animationController,
    required this.keyboardFocus,
    required this.handleHove,
    required this.startHideTimer,
    required this.cancelHideTimer,
    required this.handleDanmaku,
    required this.showVideoInfo,
    required this.showSyncPlayRoomCreateDialog,
    required this.showSyncPlayEndPointSwitchDialog,
    this.disableAnimations = false,
  });

  final void Function(BuildContext) onBackPressed;
  final Future<void> Function(double) setPlaybackSpeed;
  final void Function() showDanmakuSwitch;
  final void Function() handleDanmaku;
  final void Function() handleFullscreen;
  final void Function(ThumbDragDetails details) handleProgressBarDragStart;
  final void Function() handleProgressBarDragEnd;
  final Future<void> Function(int shaderIndex) handleSuperResolutionChange;
  final void Function() handleHove;
  final AnimationController animationController;
  final FocusNode keyboardFocus;
  final void Function() startHideTimer;
  final void Function() cancelHideTimer;
  final void Function() showVideoInfo;
  final void Function() showSyncPlayRoomCreateDialog;
  final void Function() showSyncPlayEndPointSwitchDialog;
  final bool disableAnimations;

  @override
  ConsumerState<SmallestPlayerItemPanel> createState() =>
      _SmallestPlayerItemPanelState();
}

class _SmallestPlayerItemPanelState
    extends ConsumerState<SmallestPlayerItemPanel> {
  late final VideoPageController videoPageController;
  late final PlayerController playerController;
  late Animation<Offset> topOffsetAnimation;
  late Animation<Offset> bottomOffsetAnimation;

  @override
  void initState() {
    super.initState();
    playerController = ref.read(playerControllerProvider.notifier);
    videoPageController = ref.read(videoControllerProvider.notifier);
    topOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOut,
      ),
    );
    bottomOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void showForwardChange() {
    final t = context.t;
    KazumiDialog.show(builder: (context) {
      String input = '';
      return AlertDialog(
        title: Text(t.playback.controls.skip.title),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: playerController.forwardTime.toString(),
              ),
              onChanged: (value) {
                input = value;
              },
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => KazumiDialog.dismiss(),
            child: Text(
              t.app.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (input.isNotEmpty) {
                playerController.setForwardTime(int.parse(input));
              }
              KazumiDialog.dismiss();
            },
            child: Text(t.app.confirm),
          ),
        ],
      );
    });
  }

  Widget forwardIcon() {
    final t = context.t;
    return Tooltip(
      message: t.playback.controls.skip.tooltip,
      child: GestureDetector(
        onLongPress: showForwardChange,
        child: IconButton(
          icon: Image.asset(
            'assets/images/forward_80.png',
            color: Colors.white,
            height: 24,
          ),
          onPressed: () {
            playerController.seek(
              playerController.currentPosition +
                  Duration(seconds: playerController.forwardTime),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerControllerProvider);
    final videoState = ref.watch(videoControllerProvider);
    final shouldShowOverlay = widget.disableAnimations
        ? playerState.showVideoController
        : true;
    final canShowControls = !playerState.lockPanel && shouldShowOverlay;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          top: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: canShowControls,
            child: widget.disableAnimations
                ? _buildTopGradient()
                : SlideTransition(
                    position: topOffsetAnimation,
                    child: _buildTopGradient(),
                  ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          bottom: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: canShowControls,
            child: widget.disableAnimations
                ? _buildBottomGradient()
                : SlideTransition(
                    position: bottomOffsetAnimation,
                    child: _buildBottomGradient(),
                  ),
          ),
        ),
        Positioned(
          top: 25,
          child: playerState.showSeekTime
              ? _buildInfoChip(
                  _buildSeekStatusText(playerState),
                )
              : const SizedBox.shrink(),
        ),
        Positioned(
          top: 25,
          child: playerState.showPlaySpeed
              ? _buildInfoChipWidget(
                  Row(
                    children: [
                      const Icon(Icons.fast_forward, color: Colors.white),
                      Text(
                        ' ${context.t.playback.controls.status.speed}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Positioned(
          top: 25,
          child: playerState.showBrightness
              ? _buildInfoChipWidget(
                  Row(
                    children: [
                      const Icon(Icons.brightness_7, color: Colors.white),
                      Text(
                        '  %',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Positioned(
          top: 25,
          child: playerState.showVolume
              ? _buildInfoChipWidget(
                  Row(
                    children: [
                      const Icon(Icons.volume_down, color: Colors.white),
                      Text(
                        ' %',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: canShowControls,
            child: widget.disableAnimations
                ? _buildTopControlWidget(playerState, videoState)
                : SlideTransition(
                    position: topOffsetAnimation,
                    child: _buildTopControlWidget(playerState, videoState),
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: canShowControls,
            child: widget.disableAnimations
                ? _buildBottomControlWidget(playerState, videoState)
                : SlideTransition(
                    position: bottomOffsetAnimation,
                    child: _buildBottomControlWidget(playerState, videoState),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopGradient() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black45,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomGradient() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black45,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControlWidget(
    PlayerState playerState,
    VideoPageState videoState,
  ) {
    return Row(
      children: [
        IconButton(
          color: Colors.white,
          icon: Icon(
            playerState.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
          ),
          onPressed: playerController.playOrPause,
        ),
        Expanded(
          child: ProgressBar(
            thumbRadius: 8,
            thumbGlowRadius: 18,
            timeLabelLocation: TimeLabelLocation.none,
            progress: playerState.currentPosition,
            buffered: playerState.buffer,
            total: playerState.duration,
            onSeek: playerController.seek,
            onDragStart: widget.handleProgressBarDragStart,
            onDragUpdate: (details) {
              playerController.currentPosition = details.timeStamp;
            },
            onDragEnd: widget.handleProgressBarDragEnd,
          ),
        ),
        Text(
          '     / ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontFeatures: [
              FontFeature.tabularFigures(),
            ],
          ),
        ),
        videoState.isPip
            ? const SizedBox(width: 16)
            : IconButton(
                color: Colors.white,
                icon: Icon(
                  videoState.isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                ),
                onPressed: widget.handleFullscreen,
              ),
      ],
    );
  }

  Widget _buildTopControlWidget(
    PlayerState playerState,
    VideoPageState videoState,
  ) {
    final t = context.t;
    final svgString = danmakuOnSvg.replaceFirst(
      '00AEEC',
      Theme.of(context)
          .colorScheme
          .primary
          .toARGB32()
          .toRadixString(16)
          .substring(2),
    );

    return EmbeddedNativeControlArea(
      child: Row(
        children: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              widget.onBackPressed(context);
            },
          ),
          const Expanded(
            child: dtb.DragToMoveArea(child: SizedBox(height: 40)),
          ),
          forwardIcon(),
          if (Utils.isDesktop())
            IconButton(
              onPressed: () {
                if (videoState.isPip) {
                  Utils.exitDesktopPIPWindow();
                } else {
                  Utils.enterDesktopPIPWindow();
                }
                videoPageController.isPip = !videoState.isPip;
              },
              icon: const Icon(
                Icons.picture_in_picture,
                color: Colors.white,
              ),
            ),
          IconButton(
            color: Colors.white,
            icon: playerState.danmakuOn
                ? SvgPicture.string(
                    svgString,
                    height: 24,
                  )
                : SvgPicture.asset(
                    'assets/images/danmaku_off.svg',
                    height: 24,
                  ),
            onPressed: widget.handleDanmaku,
            tooltip: playerState.danmakuOn
                ? t.playback.controls.tooltips.danmakuOn
                : t.playback.controls.tooltips.danmakuOff,
          ),
          CollectButton(
            bangumiItem: videoPageController.bangumiItem,
            onOpen: () {
              widget.cancelHideTimer();
              playerController.setCanHidePlayerPanel(false);
            },
            onClose: () {
              widget.cancelHideTimer();
              widget.startHideTimer();
              playerController.setCanHidePlayerPanel(true);
            },
          ),
          MenuAnchor(
            consumeOutsideTap: true,
            onOpen: () {
              widget.cancelHideTimer();
              playerController.setCanHidePlayerPanel(false);
            },
            onClose: () {
              widget.cancelHideTimer();
              widget.startHideTimer();
              playerController.setCanHidePlayerPanel(true);
            },
            builder:
                (BuildContext context, MenuController controller, Widget? _) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              );
            },
            menuChildren: [
              SubmenuButton(
                menuChildren: List<MenuItemButton>.generate(
                  3,
                  (int index) => MenuItemButton(
                    onPressed: () =>
                        playerController.setAspectRatioType(index + 1),
                    child: _buildMenuItem(
                      title: index + 1 == 1
                          ? t.playback.controls.aspectRatio.options.auto
                          : index + 1 == 2
                              ? t.playback.controls.aspectRatio.options.crop
                              : t.playback.controls.aspectRatio.options.stretch,
                      highlighted: index + 1 == playerState.aspectRatioType,
                    ),
                  ),
                ),
                child: _buildMenuItem(title: t.playback.controls.aspectRatio.label),
              ),
              SubmenuButton(
                menuChildren: [
                  for (final double speed in defaultPlaySpeedList)
                    MenuItemButton(
                      onPressed: () async {
                        await widget.setPlaybackSpeed(speed);
                      },
                      child: _buildMenuItem(
                        title: '${speed}x',
                        highlighted: speed == playerState.playerSpeed,
                      ),
                    ),
                ],
                child: _buildMenuItem(title: t.playback.controls.speedMenu.label),
              ),
              SubmenuButton(
                menuChildren: List<MenuItemButton>.generate(
                  3,
                  (int index) => MenuItemButton(
                    onPressed: () =>
                        widget.handleSuperResolutionChange(index + 1),
                    child: _buildMenuItem(
                      title: index + 1 == 1
                          ? t.playback.controls.superResolution.off
                          : index + 1 == 2
                              ? t.playback.controls.superResolution.balanced
                              : t.playback.controls.superResolution.quality,
                      highlighted:
                          playerState.superResolutionType == index + 1,
                    ),
                  ),
                ),
                child: _buildMenuItem(title: t.playback.controls.superResolution.label),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    child: _buildMenuItem(
                      title: t.playback.controls.syncplay.room.replaceFirst(
                        '{name}',
                        playerState.syncplayRoom.isEmpty
                            ? t.playback.controls.syncplay.roomEmpty
                            : playerState.syncplayRoom,
                      ),
                    ),
                  ),
                  MenuItemButton(
                    child: _buildMenuItem(
                      title: t.playback.controls.syncplay.latency.replaceFirst(
                        '{ms}',
                        playerState.syncplayClientRtt.toString(),
                      ),
                    ),
                  ),
                  MenuItemButton(
                    onPressed: widget.showSyncPlayRoomCreateDialog,
                    child: _buildMenuItem(
                        title: t.playback.controls.syncplay.join),
                  ),
                  MenuItemButton(
                    onPressed: widget.showSyncPlayEndPointSwitchDialog,
                    child: _buildMenuItem(
                        title: t.playback.controls.syncplay.switchServer),
                  ),
                  MenuItemButton(
                    onPressed: () async {
                      await playerController.exitSyncPlayRoom();
                    },
                    child: _buildMenuItem(
                        title: t.playback.controls.syncplay.disconnect),
                  ),
                ],
                child: _buildMenuItem(title: t.playback.controls.syncplay.label),
              ),
              MenuItemButton(
                onPressed: widget.showDanmakuSwitch,
                child: _buildMenuItem(title: t.playback.controls.menu.danmakuToggle),
              ),
              MenuItemButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height * 3 / 4,
                      maxWidth: (Utils.isDesktop() || Utils.isTablet())
                          ? MediaQuery.of(context).size.width * 9 / 16
                          : MediaQuery.of(context).size.width,
                    ),
                    clipBehavior: Clip.antiAlias,
                    context: context,
                    builder: (context) {
                      return DanmakuSettingsSheet(
                        danmakuController: playerController.danmakuController,
                      );
                    },
                  );
                },
                child: _buildMenuItem(title: t.settings.player.danmakuSettings),
              ),
              MenuItemButton(
                onPressed: widget.showVideoInfo,
                child: _buildMenuItem(title: t.playback.controls.menu.videoInfo),
              ),
              MenuItemButton(
                onPressed: () {
                  final needRestart = playerState.playing;
                  playerController.pause();
                  RemotePlay()
                      .castVideo(
                        playerController.videoUrl,
                        videoPageController.currentPlugin.referer,
                      )
                      .whenComplete(() {
                    if (needRestart) {
                      playerController.play();
                    }
                  });
                },
                child: _buildMenuItem(title: t.playback.controls.menu.cast),
              ),
              MenuItemButton(
                onPressed: playerController.lanunchExternalPlayer,
                child: _buildMenuItem(title: t.playback.controls.menu.external),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    bool highlighted = false,
  }) {
    return Container(
      height: 48,
      constraints: const BoxConstraints(minWidth: 112),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: highlighted
            ? TextStyle(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
    );
  }

  String _buildSeekStatusText(PlayerState playerState) {
    final t = context.t;
    final diffSeconds = (playerState.currentPosition -
            playerController.playerPosition)
        .inSeconds
        .abs();
    final template =
        playerState.currentPosition.compareTo(playerController.playerPosition) >
                0
            ? t.playback.controls.status.fastForward
            : t.playback.controls.status.rewind;
    return template.replaceFirst('{seconds}', diffSeconds.toString());
  }

  Widget _buildInfoChip(String text) {
    return _buildInfoChipWidget(
      Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildInfoChipWidget(Widget child) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: child,
        ),
      ],
    );
  }
}
