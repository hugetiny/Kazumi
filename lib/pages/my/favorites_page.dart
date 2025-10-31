import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/card/bangumi_card.dart';
import 'package:kazumi/bean/widget/collect_button.dart';
import 'package:kazumi/modules/collect/collect_module.dart';
import 'package:kazumi/pages/menu/navigation_provider.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/pages/my/providers.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  static const List<int> _visibleTypes = [1, 2, 4];

  late final CollectController collectController;
  late final TabController tabController;
  bool showDelete = false;
  bool syncing = false;
  late final Box setting;

  @override
  void initState() {
    super.initState();
    collectController = ref.read(collectControllerProvider.notifier);
    tabController = TabController(vsync: this, length: _visibleTypes.length);
    setting = GStorage.setting;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void _onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
    ref.read(navigationBarControllerProvider.notifier).updateSelectedIndex(0);
    context.go('/tab/popular');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final favoritesTexts = t.library.my.favorites;
    final collectibles = ref.watch(collectControllerProvider).collectibles
        .where((item) => _visibleTypes.contains(item.type))
        .toList();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _onBackPressed(context);
      },
      child: Scaffold(
        appBar: SysAppBar(
          needTopOffset: false,
          toolbarHeight: 104,
          bottom: TabBar(
            controller: tabController,
            tabs: _buildTabs(favoritesTexts.tabs),
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
          title: Text(favoritesTexts.title),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  showDelete = !showDelete;
                });
              },
              icon: showDelete
                  ? const Icon(Icons.edit_outlined)
                  : const Icon(Icons.edit),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final webDavEnable =
                setting.get(SettingBoxKey.webDavEnable, defaultValue: false)
                        as bool? ??
                    false;
            if (!webDavEnable) {
              KazumiDialog.showToast(
                message: favoritesTexts.sync.disabled,
              );
              return;
            }
            if (showDelete) {
              KazumiDialog.showToast(
                message: favoritesTexts.sync.editing,
              );
              return;
            }
            if (syncing) {
              return;
            }
            setState(() {
              syncing = true;
            });
            await collectController.syncCollectibles();
            if (mounted) {
              setState(() {
                syncing = false;
              });
            }
          },
          child: syncing
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.cloud_sync),
        ),
        body: collectibles.isEmpty
            ? Center(child: Text(favoritesTexts.empty))
            : TabBarView(
                controller: tabController,
                children: List.generate(
                  _visibleTypes.length,
                  (index) => _buildTab(
                    collectibles,
                    context,
                    _visibleTypes[index],
                    favoritesTexts.tabs.empty,
                  ),
                ),
              ),
      ),
    );
  }

  List<Tab> _buildTabs(dynamic tabs) => [
        Tab(text: tabs.watching),
        Tab(text: tabs.planned),
        Tab(text: tabs.completed),
      ];

  Widget _buildTab(
    List<CollectedBangumi> collectibles,
    BuildContext context,
    int type,
    String emptyText,
  ) {
    final filtered = collectibles
        .where((item) => item.type == type)
        .toList()
      ..sort(
        (a, b) => b.time.millisecondsSinceEpoch
            .compareTo(a.time.millisecondsSinceEpoch),
      );

    if (filtered.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(emptyText)),
          ),
        ],
      );
    }

    final crossCount = _resolveCrossCount(MediaQuery.sizeOf(context).width);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            StyleString.cardSpace,
            StyleString.cardSpace,
            StyleString.cardSpace,
            0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: StyleString.cardSpace - 2,
              crossAxisSpacing: StyleString.cardSpace,
              crossAxisCount: crossCount,
              mainAxisExtent: _resolveMainAxisExtent(context, crossCount),
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final bangumi = filtered[index];
                return Stack(
                  children: [
                    BangumiCardV(
                      bangumiItem: bangumi.bangumiItem,
                      canTap: !showDelete,
                    ),
                    if (showDelete)
                      Positioned(
                        right: 5,
                        bottom: 5,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: CollectButton(
                            bangumiItem: bangumi.bangumiItem,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                  ],
                );
              },
              childCount: filtered.length,
            ),
          ),
        ),
      ],
    );
  }

  int _resolveCrossCount(double width) {
    if (width < 480) {
      return 2;
    }
    if (width < LayoutBreakpoint.compact['width']!) {
      return 3;
    }
    if (width < LayoutBreakpoint.medium['width']!) {
      return 5;
    }
    return 6;
  }

  double _resolveMainAxisExtent(BuildContext context, int crossCount) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width / crossCount;
    return cardWidth / 0.65 +
        MediaQuery.textScalerOf(context).scale(32.0);
  }
}
