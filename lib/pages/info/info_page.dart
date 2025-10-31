import 'dart:io';
import 'dart:ui';
import 'package:kazumi/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/bean/widget/collect_button.dart';
import 'package:kazumi/bean/widget/embedded_native_control_area.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/pages/info/providers.dart';
import 'package:kazumi/bean/card/bangumi_info_card.dart';
import 'package:kazumi/pages/info/source_sheet.dart';
import 'package:kazumi/pages/video/providers.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/bean/card/network_img_layer.dart';
import 'package:logger/logger.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/pages/info/info_tabview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/bean/appbar/drag_to_move_bar.dart' as dtb;
import 'package:kazumi/l10n/generated/translations.g.dart';

class InfoPage extends ConsumerStatefulWidget {
  const InfoPage({super.key, this.bangumi});

  final BangumiItem? bangumi;

  @override
  ConsumerState<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends ConsumerState<InfoPage>
    with TickerProviderStateMixin {
  late final InfoController infoController;
  late final VideoPageController videoPageController;
  late TabController infoTabController;

  bool commentsIsLoading = false;
  bool charactersIsLoading = false;
  bool commentsQueryTimeout = false;
  bool charactersQueryTimeout = false;
  bool staffIsLoading = false;
  bool staffQueryTimeout = false;

  Future<void> loadCharacters() async {
    if (charactersIsLoading) return;
    setState(() {
      charactersIsLoading = true;
      charactersQueryTimeout = false;
    });
  infoController
    .queryBangumiCharactersByID(infoController.bangumiItem.id)
        .then((_) {
      if (infoController.characterList.isEmpty && mounted) {
        setState(() {
          charactersIsLoading = false;
          charactersQueryTimeout = true;
        });
      }
      if (infoController.characterList.isNotEmpty && mounted) {
        setState(() {
          charactersIsLoading = false;
        });
      }
    });
  }

  Future<void> loadStaff() async {
    if (staffIsLoading) return;
    setState(() {
      staffIsLoading = true;
      staffQueryTimeout = false;
    });
  infoController
    .queryBangumiStaffsByID(infoController.bangumiItem.id)
        .then((_) {
      if (infoController.staffList.isEmpty && mounted) {
        setState(() {
          staffIsLoading = false;
          staffQueryTimeout = true;
        });
      }
      if (infoController.staffList.isNotEmpty && mounted) {
        setState(() {
          staffIsLoading = false;
        });
      }
    });
  }

  Future<void> loadMoreComments({int offset = 0}) async {
    if (commentsIsLoading) return;
    setState(() {
      commentsIsLoading = true;
      commentsQueryTimeout = false;
    });
  infoController
    .queryBangumiCommentsByID(infoController.bangumiItem.id, offset: offset)
        .then((_) {
      if (infoController.commentsList.isEmpty && mounted) {
        setState(() {
          commentsIsLoading = false;
          commentsQueryTimeout = true;
        });
      }
      if (infoController.commentsList.isNotEmpty && mounted) {
        setState(() {
          commentsIsLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    infoController = ref.read(infoControllerProvider.notifier);
    videoPageController = ref.read(videoControllerProvider.notifier);
    final BangumiItem? initialBangumi = widget.bangumi;

    // Delay provider state modifications until after initState completes
    Future.microtask(() {
      if (!mounted) return;

      if (initialBangumi != null) {
        infoController.bangumiItem = initialBangumi;
      }
      infoController.resetListsForNewBangumi();
      videoPageController.currentEpisode = 1;

      // Query bangumi info asynchronously if needed
      if (infoController.bangumiItem.summary == '' ||
          infoController.bangumiItem.votesCount.isEmpty) {
        queryBangumiInfoByID(infoController.bangumiItem.id, type: 'attach');
      }
    });

    infoTabController = TabController(length: 5, vsync: this);
    infoTabController.addListener(() {
      int index = infoTabController.index;
      if (index == 1 &&
          infoController.commentsList.isEmpty &&
          !commentsIsLoading) {
        loadMoreComments();
      }
      if (index == 2 &&
          infoController.characterList.isEmpty &&
          !charactersIsLoading) {
        loadCharacters();
      }
      if (index == 4 && infoController.staffList.isEmpty && !staffIsLoading) {
        loadStaff();
      }
    });
  }

  @override
  void dispose() {
    infoTabController.dispose();
    super.dispose();
  }

  Future<void> queryBangumiInfoByID(int id, {String type = "init"}) async {
    try {
      await infoController.queryBangumiInfoByID(id, type: type);
      setState(() {});
    } catch (e) {
      KazumiLogger().log(Level.error, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(infoControllerProvider);
    final infoTexts = context.t.library.info;
    final metadataTexts = infoTexts.metadata;
    final List<String> tabs = <String>[
      infoTexts.tabs.overview,
      infoTexts.tabs.comments,
      infoTexts.tabs.characters,
      infoTexts.tabs.reviews,
      infoTexts.tabs.staff,
    ];
    final bool showWindowButton = GStorage.setting
        .get(SettingBoxKey.showWindowButton, defaultValue: false);
    return PopScope(
      canPop: true,
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar.medium(
                    title: EmbeddedNativeControlArea(
                      child: dtb.DragToMoveArea(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            infoController.bangumiItem.nameCn == ''
                                ? infoController.bangumiItem.name
                                : infoController.bangumiItem.nameCn,
                          ),
                        ),
                      ),
                    ),
                    automaticallyImplyLeading: false,
                    scrolledUnderElevation: 0.0,
                    leading: EmbeddedNativeControlArea(
                      child: IconButton(
                        onPressed: () {
                          Navigator.maybePop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                    actions: [
                      EmbeddedNativeControlArea(
                        child: IconButton(
                          tooltip: metadataTexts.refresh,
                          onPressed: state.metadataLoading
                              ? null
                              : () {
                                  infoController.refreshMetadata(
                                    forceRefresh: true,
                                  );
                                },
                          icon: state.metadataLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                        ),
                      ),
                      if (innerBoxIsScrolled)
                        EmbeddedNativeControlArea(
                          child: CollectButton(
                            bangumiItem: infoController.bangumiItem,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      EmbeddedNativeControlArea(
                        child: IconButton(
                          onPressed: () {
                            launchUrl(
                              Uri.parse(
                                  'https://bangumi.tv/subject/${infoController.bangumiItem.id}'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.open_in_browser_rounded),
                        ),
                      ),
                      if (!showWindowButton && Utils.isDesktop())
                        CloseButton(onPressed: () => windowManager.close()),
                      SizedBox(width: 8),
                    ],
                    toolbarHeight: (Platform.isMacOS && showWindowButton)
                        ? kToolbarHeight + 22
                        : kToolbarHeight,
                    stretch: true,
                    centerTitle: false,
                    expandedHeight: (Platform.isMacOS && showWindowButton)
                        ? 308 + kTextTabBarHeight + kToolbarHeight + 22
                        : 308 + kTextTabBarHeight + kToolbarHeight,
                    collapsedHeight: (Platform.isMacOS && showWindowButton)
                        ? kTextTabBarHeight +
                            kToolbarHeight +
                            MediaQuery.paddingOf(context).top +
                            22
                        : kTextTabBarHeight +
                            kToolbarHeight +
                            MediaQuery.paddingOf(context).top,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        children: [
                          if (!state.isLoading)
                            Positioned.fill(
                              bottom: kTextTabBarHeight,
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: 0.4,
                                  child: LayoutBuilder(
                                    builder: (context, boxConstraints) {
                                      return ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                            sigmaX: 15.0, sigmaY: 15.0),
                                        child: ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white,
                                                Colors.transparent,
                                              ],
                                              stops: [0.8, 1],
                                            ).createShader(bounds);
                                          },
                                          child: NetworkImgLayer(
                                            src: infoController
                                                    .bangumiItem.images['large'] ??
                                                '',
                                            width: boxConstraints.maxWidth,
                                            height: boxConstraints.maxHeight,
                                            fadeInDuration:
                                                const Duration(milliseconds: 0),
                                            fadeOutDuration:
                                                const Duration(milliseconds: 0),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          SafeArea(
                            bottom: false,
                            child: EmbeddedNativeControlArea(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, kToolbarHeight, 16, 0),
                                  child: BangumiInfoCardV(
                                    bangumiItem: infoController.bangumiItem,
                                    isLoading: state.isLoading,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                      controller: infoTabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      dividerHeight: 0,
                      tabs: tabs.map((name) => Tab(text: name)).toList(),
                    ),
                  ),
                ),
              ];
            },
            body: InfoTabView(
              tabController: infoTabController,
              bangumiItem: infoController.bangumiItem,
              commentsQueryTimeout: commentsQueryTimeout,
              charactersQueryTimeout: charactersQueryTimeout,
              staffQueryTimeout: staffQueryTimeout,
              loadMoreComments: loadMoreComments,
              loadCharacters: loadCharacters,
              loadStaff: loadStaff,
              commentsList: state.commentsList,
              characterList: state.characterList,
              staffList: state.staffList,
              isLoading: state.isLoading,
              metadataRecord: state.metadataRecord,
              metadataLoading: state.metadataLoading,
              onRefreshMetadata: () {
                infoController.refreshMetadata(forceRefresh: true);
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(infoTexts.actions.startWatching),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SourceSheet(
                    infoController: infoController,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
