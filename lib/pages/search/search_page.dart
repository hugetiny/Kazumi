import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/bean/card/bangumi_card.dart';
import 'package:kazumi/bean/widget/error_widget.dart';
import 'package:kazumi/pages/search/providers.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.inputTag = ''});

  final String inputTag;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final SearchController searchController = SearchController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    searchController.addListener(_handleSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(searchControllerProvider.notifier).loadSearchHistories();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    searchController.removeListener(_handleSearchTextChanged);
    super.dispose();
  }

  void _handleSearchTextChanged() {
    if (!mounted) return;
    if (!FocusScope.of(context).hasPrimaryFocus) return;
    if (!searchController.isOpen) {
      searchController.openView();
    }
  }

  void scrollListener() {
    final state = ref.read(searchControllerProvider);
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        searchController.text.isNotEmpty &&
        state.bangumiList.length >= 20) {
      ref
          .read(searchControllerProvider.notifier)
          .searchBangumi(searchController.text, type: 'add');
    }
  }

  void showSortSwitcher() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Wrap(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('按热度排序'),
                  onTap: () {
                    Navigator.pop(context);
                    searchController.text = ref
                        .read(searchControllerProvider.notifier)
                        .attachSortParams(searchController.text, 'heat');
                    ref
                        .read(searchControllerProvider.notifier)
                        .searchBangumi(searchController.text, type: 'init');
                  },
                ),
                ListTile(
                  title: const Text('按评分排序'),
                  onTap: () {
                    Navigator.pop(context);
                    searchController.text = ref
                        .read(searchControllerProvider.notifier)
                        .attachSortParams(searchController.text, 'rank');
                    ref
                        .read(searchControllerProvider.notifier)
                        .searchBangumi(searchController.text, type: 'init');
                  },
                ),
                ListTile(
                  title: const Text('按匹配程度排序'),
                  onTap: () {
                    Navigator.pop(context);
                    searchController.text = ref
                        .read(searchControllerProvider.notifier)
                        .attachSortParams(searchController.text, 'match');
                    ref
                        .read(searchControllerProvider.notifier)
                        .searchBangumi(searchController.text, type: 'init');
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.inputTag.isNotEmpty) {
        final String tagString = 'tag:${Uri.decodeComponent(widget.inputTag)}';
        searchController.text = tagString;
        ref
            .read(searchControllerProvider.notifier)
            .searchBangumi(tagString, type: 'init');
      }
    });
    return Scaffold(
      appBar: const SysAppBar(
        backgroundColor: Colors.transparent,
        title: Text('搜索'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showSortSwitcher,
        icon: const Icon(Icons.sort),
        label: const Text('排序方式'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: FocusScope(
              descendantsAreFocusable: false,
              child: SearchAnchor.bar(
                searchController: searchController,
                barElevation: WidgetStateProperty<double>.fromMap(
                  <WidgetStatesConstraint, double>{WidgetState.any: 0},
                ),
                viewElevation: 0,
                viewLeading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                isFullScreen: MediaQuery.sizeOf(context).width <
                    LayoutBreakpoint.compact['width']!,
                suggestionsBuilder: (context, controller) {
                  return [
                    Consumer(builder: (context, ref, _) {
                      final state = ref.watch(searchControllerProvider);
                      final query = controller.text.trim();
                      final histories = state.searchHistories;
                      final filtered = query.isEmpty
                          ? histories
                          : histories
                              .where((history) => history.keyword
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                              .toList();
                      if (filtered.isEmpty) {
                        return Container(
                          height: 400,
                          alignment: Alignment.center,
                          child: const Text('无匹配的历史记录，回车以直接检索'),
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var history in filtered.take(10))
                            ListTile(
                              key: ValueKey(history.key),
                              title: Text(history.keyword),
                              onTap: () {
                                controller.text = history.keyword;
                                ref
                                    .read(searchControllerProvider.notifier)
                                    .searchBangumi(controller.text.trim(), type: 'init');
                                if (searchController.isOpen) {
                                  searchController.closeView(history.keyword);
                                }
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () async {
                                  await ref
                                      .read(searchControllerProvider.notifier)
                                      .deleteSearchHistory(history);
                                },
                              ),
                            ),
                        ],
                      );
                    }),
                  ];
                },
                onSubmitted: (value) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .searchBangumi(value.trim(), type: 'init');
                  if (searchController.isOpen) {
                    searchController.closeView(value);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Consumer(builder: (context, ref, _) {
              final state = ref.watch(searchControllerProvider);
              if (state.isTimeOut) {
                return Center(
                  child: SizedBox(
                    height: 400,
                    child: GeneralErrorWidget(
                      errMsg: '什么都没有找到 (´;ω;`)',
                      actions: [
                        GeneralErrorButton(
                          onPressed: () {
                            ref
                                .read(searchControllerProvider.notifier)
                                .searchBangumi(searchController.text, type: 'init');
                          },
                          text: '点击重试',
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state.isLoading && state.bangumiList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              int crossCount = 3;
              if (MediaQuery.sizeOf(context).width >
                  LayoutBreakpoint.compact['width']!) {
                crossCount = 5;
              }
              if (MediaQuery.sizeOf(context).width >
                  LayoutBreakpoint.medium['width']!) {
                crossCount = 6;
              }
              final bangumiList = state.bangumiList;
              return GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: StyleString.cardSpace - 2,
                  crossAxisSpacing: StyleString.cardSpace,
                  crossAxisCount: crossCount,
                  mainAxisExtent: MediaQuery.of(context).size.width /
                          crossCount /
                          0.65 +
                      MediaQuery.textScalerOf(context).scale(32.0),
                ),
                itemCount: bangumiList.isNotEmpty ? bangumiList.length : 10,
                itemBuilder: (context, index) {
                  return bangumiList.isNotEmpty
                      ? BangumiCardV(
                          enableHero: false,
                          bangumiItem: bangumiList[index],
                        )
                      : const SizedBox.shrink();
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
