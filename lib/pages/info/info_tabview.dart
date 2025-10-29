import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/widget/error_widget.dart';
import 'package:kazumi/bean/card/comments_card.dart';
import 'package:kazumi/bean/card/character_card.dart';
import 'package:kazumi/bean/card/staff_card.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/comments/comment_item.dart';
import 'package:kazumi/modules/characters/character_item.dart';
import 'package:kazumi/modules/metadata_sync/models/metadata_record.dart';
import 'package:kazumi/modules/staff/staff_item.dart';

class InfoTabView extends StatefulWidget {
  const InfoTabView({
    super.key,
    required this.commentsQueryTimeout,
    required this.charactersQueryTimeout,
    required this.staffQueryTimeout,
    required this.tabController,
    required this.loadMoreComments,
    required this.loadCharacters,
    required this.loadStaff,
    required this.bangumiItem,
    required this.commentsList,
    required this.characterList,
    required this.staffList,
    required this.isLoading,
    required this.metadataRecord,
    required this.metadataLoading,
    this.onRefreshMetadata,
  });

  final bool commentsQueryTimeout;
  final bool charactersQueryTimeout;
  final bool staffQueryTimeout;
  final TabController tabController;
  final Future<void> Function({int offset}) loadMoreComments;
  final Future<void> Function() loadCharacters;
  final Future<void> Function() loadStaff;
  final BangumiItem bangumiItem;
  final List<CommentItem> commentsList;
  final List<CharacterItem> characterList;
  final List<StaffFullItem> staffList;
  final bool isLoading;
  final MetadataRecord? metadataRecord;
  final bool metadataLoading;
  final VoidCallback? onRefreshMetadata;

  @override
  State<InfoTabView> createState() => _InfoTabViewState();
}

class _InfoTabViewState extends State<InfoTabView>
    with SingleTickerProviderStateMixin {
  final maxWidth = 950.0;
  bool fullIntro = false;
  bool fullTag = false;
  bool showAllEpisodes = false;

  Widget get infoBody {
    final List<Widget> children = <Widget>[
      _buildMetadataStatusCard(),
      const SizedBox(height: 16),
      const Text('简介', style: TextStyle(fontSize: 18)),
      const SizedBox(height: 8),
      _buildSummarySection(),
      const SizedBox(height: 16),
      const Text('标签', style: TextStyle(fontSize: 18)),
      const SizedBox(height: 8),
      _buildTagsSection(),
    ];

    final List<Widget> episodeWidgets = _buildEpisodesSection();
    if (episodeWidgets.isNotEmpty) {
      children
        ..add(const SizedBox(height: 16))
        ..addAll(episodeWidgets);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width > maxWidth
              ? maxWidth
              : MediaQuery.sizeOf(context).width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return LayoutBuilder(builder: (context, constraints) {
      final TextSpan span = TextSpan(text: widget.bangumiItem.summary);
      final TextPainter painter =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      painter.layout(maxWidth: constraints.maxWidth);
      final int lineCount = painter.computeLineMetrics().length;
      if (lineCount > 7) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: fullIntro ? null : 120,
              width: constraints.maxWidth,
              child: SelectableText(
                widget.bangumiItem.summary,
                textAlign: TextAlign.start,
                scrollBehavior: const ScrollBehavior().copyWith(
                  scrollbars: false,
                ),
                scrollPhysics: const NeverScrollableScrollPhysics(),
                selectionHeightStyle: ui.BoxHeightStyle.max,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  fullIntro = !fullIntro;
                });
              },
              child: Text(fullIntro ? '加载更少' : '加载更多'),
            ),
          ],
        );
      }
      return SelectableText(
        widget.bangumiItem.summary,
        textAlign: TextAlign.start,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        selectionHeightStyle: ui.BoxHeightStyle.max,
      );
    });
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: Utils.isDesktop() ? 8 : 0,
      children: List<Widget>.generate(
          fullTag || widget.bangumiItem.tags.length < 13
              ? widget.bangumiItem.tags.length
              : 13, (int index) {
        if (!fullTag && index == 12) {
          return ActionChip(
            label: Text(
              '更多 +',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onPressed: () {
              setState(() {
                fullTag = !fullTag;
              });
            },
          );
        }
        return ActionChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${widget.bangumiItem.tags[index].name} '),
              Text(
                '${widget.bangumiItem.tags[index].count}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          onPressed: () {
            context.push(
              '/search',
              extra: widget.bangumiItem.tags[index].name,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildMetadataStatusCard() {
    final MetadataRecord? record = widget.metadataRecord;
    final Widget? refreshButton = widget.onRefreshMetadata == null
        ? null
        : TextButton.icon(
            onPressed:
                widget.metadataLoading ? null : widget.onRefreshMetadata,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('刷新'),
          );

    if (widget.metadataLoading && record == null) {
      return Card(
        child: ListTile(
          leading: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: const Text('正在同步元数据…'),
          subtitle: const Text('首次同步可能需要几秒钟。'),
          trailing: refreshButton,
        ),
      );
    }

    if (record == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: const Text('尚未获取官方元数据'),
          subtitle: const Text('稍后重试或检查设置中的元数据开关。'),
          trailing: refreshButton,
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                widget.metadataLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '元数据来自 ${_sourceDisplayName(record.activeSource)}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (refreshButton != null) refreshButton,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '最后更新：${_formatUpdatedAt(record.updatedAt)} · 语言：${record.localeTag.isEmpty ? '系统默认' : record.localeTag}',
              style: theme.textTheme.bodySmall,
            ),
            if (record.identifiers.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: record.identifiers.entries
                    .map(
                      (entry) => Chip(
                        label: Text(
                          '${entry.key.toUpperCase()}: ${entry.value}',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEpisodesSection() {
    final MetadataRecord? record = widget.metadataRecord;
    if (record == null || record.episodes.isEmpty) {
      return const <Widget>[];
    }

    final List<EpisodeMetadata> episodes = record.episodes;
    final List<EpisodeMetadata> visibleEpisodes = showAllEpisodes
        ? episodes
        : episodes.take(10).toList(growable: false);

    return <Widget>[
      Row(
        children: [
          const Text('剧集', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          if (widget.metadataLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const Spacer(),
          if (episodes.length > visibleEpisodes.length)
            TextButton(
              onPressed: () {
                setState(() {
                  showAllEpisodes = !showAllEpisodes;
                });
              },
              child: Text(
                showAllEpisodes ? '收起' : '展开全部 (${episodes.length})',
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final EpisodeMetadata episode = visibleEpisodes[index];
          return _buildEpisodeTile(episode);
        },
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemCount: visibleEpisodes.length,
      ),
    ];
  }

  Widget _buildEpisodeTile(EpisodeMetadata episode) {
    final ThemeData theme = Theme.of(context);
    final String title = (episode.title?.trim().isNotEmpty ?? false)
        ? episode.title!.trim()
        : '第${episode.number}话';
    final String metadataLine =
        '${_formatEpisodeDate(episode.airDate)} · ${_formatEpisodeRuntime(episode.runtimeMinutes)}';
    final String synopsis = (episode.synopsis ?? '').trim();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        child: Text(episode.number.toString()),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metadataLine, style: theme.textTheme.bodySmall),
          if (synopsis.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                synopsis,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  String _formatUpdatedAt(DateTime time) {
    final DateTime local = time.toLocal();
    return '${local.year.toString()}-${_twoDigits(local.month)}-${_twoDigits(local.day)} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _formatEpisodeDate(DateTime? time) {
    if (time == null) {
      return '日期待定';
    }
    final DateTime local = time.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)}';
  }

  String _formatEpisodeRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) {
      return '时长未知';
    }
    return '$minutes 分钟';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _sourceDisplayName(String? source) {
    switch (source) {
      case 'bangumi':
        return 'Bangumi';
      case 'tmdb':
        return 'TMDb';
      case null:
        return '多源合并';
      default:
        return source.toUpperCase();
    }
  }

  /// Bone for Skeleton Loader
  Widget get infoBodyBone {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width > maxWidth
              ? maxWidth
              : MediaQuery.sizeOf(context).width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeletonizer.zone(child: Bone.multiText(lines: 3)),
              const SizedBox(height: 16),
              Skeletonizer.zone(child: Bone.text(fontSize: 18, width: 50)),
              const SizedBox(height: 8),
              Skeletonizer.zone(child: Bone.multiText(lines: 7)),
              const SizedBox(height: 16),
              Skeletonizer.zone(child: Bone.text(fontSize: 18, width: 50)),
              const SizedBox(height: 8),
              if (widget.isLoading)
                Skeletonizer.zone(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(
                        4, (_) => Bone.button(uniRadius: 8, height: 32)),
                  ),
                ),
              const SizedBox(height: 16),
              if (widget.isLoading) ...[
                Skeletonizer.zone(child: Bone.text(fontSize: 18, width: 60)),
                const SizedBox(height: 8),
                Skeletonizer.zone(child: Bone.multiText(lines: 2)),
                const SizedBox(height: 12),
                Skeletonizer.zone(child: Bone.multiText(lines: 2)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget get commentsListBody {
    return Builder(
      builder: (BuildContext context) {
        return NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              widget.loadMoreComments(offset: widget.commentsList.length);
            }
            return true;
          },
          child: CustomScrollView(
            scrollBehavior: const ScrollBehavior().copyWith(
              scrollbars: false,
            ),
            key: PageStorageKey<String>('吐槽'),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverLayoutBuilder(builder: (context, _) {
                if (widget.commentsList.isNotEmpty) {
                  return SliverList.separated(
                    addAutomaticKeepAlives: false,
                    itemCount: widget.commentsList.length,
                    itemBuilder: (context, index) {
                      return SafeArea(
                        top: false,
                        bottom: false,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width > maxWidth
                                  ? maxWidth
                                  : MediaQuery.sizeOf(context).width - 32,
                              child: CommentsCard(
                                commentItem: widget.commentsList[index],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SafeArea(
                        top: false,
                        bottom: false,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width > maxWidth
                                  ? maxWidth
                                  : MediaQuery.sizeOf(context).width - 32,
                              child: Divider(
                                  thickness: 0.5, indent: 10, endIndent: 10),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                if (widget.commentsQueryTimeout) {
                  return SliverFillRemaining(
                    child: GeneralErrorWidget(
                      errMsg: '获取失败，请重试',
                      actions: [
                        GeneralErrorButton(
                          onPressed: () {
                            widget.loadMoreComments(
                                offset: widget.commentsList.length);
                          },
                          text: '重试',
                        ),
                      ],
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: 4,
                  itemBuilder: (context, _) {
                    return SafeArea(
                      top: false,
                      bottom: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width > maxWidth
                                ? maxWidth
                                : MediaQuery.sizeOf(context).width - 32,
                            child: CommentsCard.bone(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              })
            ],
          ),
        );
      },
    );
  }

  Widget get staffListBody {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          scrollBehavior: const ScrollBehavior().copyWith(
            scrollbars: false,
          ),
          key: PageStorageKey<String>('制作人员'),
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverLayoutBuilder(builder: (context, _) {
              if (widget.staffList.isNotEmpty) {
                return SliverList.builder(
                  itemCount: widget.staffList.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width > maxWidth
                              ? maxWidth
                              : MediaQuery.sizeOf(context).width - 32,
                          child: StaffCard(
                            staffFullItem: widget.staffList[index],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              if (widget.staffQueryTimeout) {
                return SliverFillRemaining(
                  child: GeneralErrorWidget(
                    errMsg: '获取失败，请重试',
                    actions: [
                      GeneralErrorButton(
                        onPressed: () {
                          widget.loadStaff();
                        },
                        text: '重试',
                      ),
                    ],
                  ),
                );
              }
              return SliverList.builder(
                itemCount: 8,
                itemBuilder: (context, _) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width > maxWidth
                          ? maxWidth
                          : MediaQuery.sizeOf(context).width - 32,
                      child: Skeletonizer.zone(
                        child: ListTile(
                          leading: Bone.circle(size: 36),
                          title: Bone.text(width: 100),
                          subtitle: Bone.text(width: 80),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget get charactersListBody {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          scrollBehavior: const ScrollBehavior().copyWith(
            scrollbars: false,
          ),
          key: PageStorageKey<String>('角色'),
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverLayoutBuilder(builder: (context, _) {
              if (widget.characterList.isNotEmpty) {
                return SliverList.builder(
                  itemCount: widget.characterList.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width > maxWidth
                              ? maxWidth
                              : MediaQuery.sizeOf(context).width - 32,
                          child: CharacterCard(
                            characterItem: widget.characterList[index],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              if (widget.charactersQueryTimeout) {
                return SliverFillRemaining(
                  child: GeneralErrorWidget(
                    errMsg: '获取失败，请重试',
                    actions: [
                      GeneralErrorButton(
                        onPressed: () {
                          widget.loadCharacters();
                        },
                        text: '重试',
                      ),
                    ],
                  ),
                );
              }
              return SliverList.builder(
                itemCount: 4,
                itemBuilder: (context, _) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width > maxWidth
                          ? maxWidth
                          : MediaQuery.sizeOf(context).width - 32,
                      child: Skeletonizer.zone(
                        child: ListTile(
                          leading: Bone.circle(size: 36),
                          title: Bone.text(width: 100),
                          subtitle: Bone.text(width: 80),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [
        Builder(
          // This Builder is needed to provide a BuildContext that is
          // "inside" the NestedScrollView, so that
          // sliverOverlapAbsorberHandleFor() can find the
          // NestedScrollView.
          builder: (BuildContext context) {
            return CustomScrollView(
              scrollBehavior: const ScrollBehavior().copyWith(
                scrollbars: false,
              ),
              // The PageStorageKey should be unique to this ScrollView;
              // it allows the list to remember its scroll position when
              // the tab view is not on the screen.
              key: PageStorageKey<String>('概览'),
              slivers: <Widget>[
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverToBoxAdapter(
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: widget.isLoading ? infoBodyBone : infoBody,
                  ),
                ),
              ],
            );
          },
        ),
        commentsListBody,
        charactersListBody,
        Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              scrollBehavior: const ScrollBehavior().copyWith(
                scrollbars: false,
              ),
              key: PageStorageKey<String>('评论'),
              slivers: <Widget>[
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                // TODO: 评论区
                SliverFillRemaining(
                  child: Center(child: Text('施工中')),
                ),
              ],
            );
          },
        ),
        staffListBody,
      ],
    );
  }
}
