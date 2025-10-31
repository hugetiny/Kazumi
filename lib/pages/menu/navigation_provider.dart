import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationBarStateData {
  final int selectedIndex;
  final bool isHidden;
  final bool isBottom;

  const NavigationBarStateData({
    this.selectedIndex = 0,
    this.isHidden = false,
    this.isBottom = false,
  });

  NavigationBarStateData copyWith({
    int? selectedIndex,
    bool? isHidden,
    bool? isBottom,
  }) {
    return NavigationBarStateData(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isHidden: isHidden ?? this.isHidden,
      isBottom: isBottom ?? this.isBottom,
    );
  }
}

class NavigationBarController extends Notifier<NavigationBarStateData> {
  @override
  NavigationBarStateData build() => const NavigationBarStateData();

  void updateSelectedIndex(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  void hideNavigate() {
    if (state.isHidden) return;
    state = state.copyWith(isHidden: true);
  }

  void showNavigate() {
    if (!state.isHidden) return;
    state = state.copyWith(isHidden: false);
  }

  void setIsBottom(bool isBottom) {
    if (state.isBottom == isBottom) return;
    state = state.copyWith(isBottom: isBottom);
  }
}

final navigationBarControllerProvider =
    NotifierProvider<NavigationBarController, NavigationBarStateData>(
  NavigationBarController.new,
);
