import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/card/episode_comments_card.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/video/providers.dart';
import 'package:kazumi/pages/video/video_state.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class EpisodeInfo extends InheritedWidget {
  /// This widget receives changes of episode and notify it's child,
  /// trigger [didChangeDependencies] of it's child.
  const EpisodeInfo({super.key, required this.episode, required super.child});

  final int episode;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static EpisodeInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EpisodeInfo>();
  }
}

class EpisodeCommentsSheet extends ConsumerStatefulWidget {
  const EpisodeCommentsSheet({super.key});

  @override
  ConsumerState<EpisodeCommentsSheet> createState() =>
      _EpisodeCommentsSheetState();
}

class _EpisodeCommentsSheetState extends ConsumerState<EpisodeCommentsSheet> {
  late final VideoPageController videoPageController;
  bool commentsQueryTimeout = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  /// episode input by [showEpisodeSelection]
  int ep = 0;

  @override
  void initState() {
    videoPageController = ref.read(videoControllerProvider.notifier);
    super.initState();
  }

  Future<void> loadComments(int episode) async {
    commentsQueryTimeout = false;
    await videoPageController
        .queryBangumiEpisodeCommentsByID(
            videoPageController.bangumiItem.id, episode)
        .then((_) {
      if (videoPageController.episodeCommentsList.isEmpty && mounted) {
        setState(() {
          commentsQueryTimeout = true;
        });
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    ep = 0;
    // wait until currentState is not null
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (videoPageController.episodeCommentsList.isEmpty) {
        // trigger RefreshIndicator onRefresh and show animation
        _refreshIndicatorKey.currentState?.show();
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildEpisodeCommentsBody(VideoPageState videoState) {
    return CustomScrollView(
      scrollBehavior: const ScrollBehavior().copyWith(
        // Scrollbars' movement is not linear so hide it.
        scrollbars: false,
        // Enable mouse drag to refresh
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad
        },
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          sliver: commentsQueryTimeout
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(context.t.library.common.emptyState),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Fix scroll issue caused by height change of network images
                      // by keeping loaded cards alive.
                      return KeepAlive(
                        keepAlive: true,
                        child: IndexedSemantics(
                          index: index,
                          child: SelectionArea(
                            child: EpisodeCommentsCard(
                              commentItem: videoState.episodeComments[index],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: videoState.episodeComments.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    addSemanticIndexes: false,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCommentsInfo(VideoPageState videoState) {
    final t = context.t;
    final currentEpisodeInfo = videoState.episodeInfo;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t.playback.comments.sectionTitle),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${currentEpisodeInfo.readType()}.${currentEpisodeInfo.episode} ${currentEpisodeInfo.name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline)),
                Text(
                    (currentEpisodeInfo.nameCn != '')
                        ? '${currentEpisodeInfo.readType()}.${currentEpisodeInfo.episode} ${currentEpisodeInfo.nameCn}'
                        : '${currentEpisodeInfo.readType()}.${currentEpisodeInfo.episode} ${currentEpisodeInfo.name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.only(left: 4.0, right: 4.0)),
              ),
              onPressed: () {
                showEpisodeSelection();
              },
              child: Text(
                t.playback.comments.manualSwitch,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 选择要查看评论的集数
  void showEpisodeSelection() {
    final TextEditingController textController = TextEditingController();
    final t = context.t;
    KazumiDialog.show(
      builder: (context) {
        return AlertDialog(
          title: Text(t.playback.comments.dialogTitle),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return TextField(
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: textController,
            );
          }),
          actions: [
            TextButton(
              onPressed: () => KazumiDialog.dismiss(),
              child: Text(
                t.app.cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isEmpty) {
                  KazumiDialog.showToast(
                    message: t.playback.comments.dialogEmpty,
                  );
                  return;
                }
                ep = int.tryParse(textController.text) ?? 0;
                if (ep == 0) {
                  return;
                }
                _refreshIndicatorKey.currentState?.show();
                KazumiDialog.dismiss();
              },
              child: Text(t.playback.comments.dialogConfirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoControllerProvider);
    final int episode = EpisodeInfo.of(context)!.episode;
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommentsInfo(videoState),
            Expanded(child: _buildEpisodeCommentsBody(videoState)),
          ],
        ),
        onRefresh: () async {
          await loadComments(ep == 0 ? episode : ep);
        },
      ),
    );
  }
}
