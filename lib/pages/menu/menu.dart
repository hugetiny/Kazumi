import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazumi/bean/widget/embedded_native_control_area.dart';
// import 'package:kazumi/pages/router.dart';
import 'navigation_provider.dart';

class ScaffoldMenu extends ConsumerStatefulWidget {
  const ScaffoldMenu({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<ScaffoldMenu> createState() => _ScaffoldMenu();
}
class _ScaffoldMenu extends ConsumerState<ScaffoldMenu> {

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationBarControllerProvider);
    final navigationController =
        ref.read(navigationBarControllerProvider.notifier);

    return OrientationBuilder(builder: (context, orientation) {
      final bool isPortrait = orientation == Orientation.portrait;
      navigationController.setIsBottom(isPortrait);
      return isPortrait
          ? bottomMenuWidget(context, navigationState, navigationController)
          : sideMenuWidget(context, navigationState, navigationController);
    });
  }

  Widget bottomMenuWidget(
    BuildContext context,
    NavigationBarStateData state,
    NavigationBarController controller,
  ) {
    return Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: widget.child ?? const SizedBox.shrink(),
        ),
        bottomNavigationBar: state.isHidden
            ? const SizedBox(height: 0)
            : NavigationBar(
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.home),
                    icon: Icon(Icons.home_outlined),
                    label: '推荐',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.timeline),
                    icon: Icon(Icons.timeline_outlined),
                    label: '时间表',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.favorite),
                    icon: Icon(Icons.favorite_outlined),
                    label: '追番',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.settings),
                    icon: Icon(Icons.settings),
                    label: '我的',
                  ),
                ],
                selectedIndex: state.selectedIndex,
                onDestinationSelected: (int index) {
                  controller.updateSelectedIndex(index);
                  switch (index) {
                    case 0:
                      context.go('/tab/popular');
                      break;
                    case 1:
                      context.go('/tab/timeline');
                      break;
                    case 2:
                      context.go('/tab/collect');
                      break;
                    case 3:
                      context.go('/tab/my');
                      break;
                  }
                },
              ));
  }

  Widget sideMenuWidget(
    BuildContext context,
    NavigationBarStateData state,
    NavigationBarController controller,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Row(
        children: [
          EmbeddedNativeControlArea(
            child: Visibility(
              visible: !state.isHidden,
              child: NavigationRail(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                groupAlignment: 1.0,
                leading: FloatingActionButton(
                  elevation: 0,
                  heroTag: null,
                  onPressed: () {
                    context.push('/search');
                  },
                  child: const Icon(Icons.search),
                ),
                labelType: NavigationRailLabelType.selected,
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.home),
                    icon: Icon(Icons.home_outlined),
                    label: Text('推荐'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.timeline),
                    icon: Icon(Icons.timeline_outlined),
                    label: Text('时间表'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.favorite),
                    icon: Icon(Icons.favorite_border),
                    label: Text('追番'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.settings),
                    icon: Icon(Icons.settings_outlined),
                    label: Text('我的'),
                  ),
                ],
                selectedIndex: state.selectedIndex,
                onDestinationSelected: (int index) {
                  controller.updateSelectedIndex(index);
                  switch (index) {
                    case 0:
                      context.go('/tab/popular');
                      break;
                    case 1:
                      context.go('/tab/timeline');
                      break;
                    case 2:
                      context.go('/tab/collect');
                      break;
                    case 3:
                      context.go('/tab/my');
                      break;
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
