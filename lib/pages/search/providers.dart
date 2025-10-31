import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/search/search_controller.dart';

final searchControllerProvider =
    NotifierProvider<SearchPageController, SearchPageState>(
  SearchPageController.new,
);