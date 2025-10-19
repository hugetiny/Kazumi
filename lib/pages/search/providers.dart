import 'package:riverpod/riverpod.dart';
import 'package:kazumi/pages/search/search_controller.dart';

final searchControllerProvider = StateNotifierProvider<SearchPageController, SearchPageState>((ref) {
  return SearchPageController();
});