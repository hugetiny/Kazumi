import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'popular_controller.dart';

/// Popular 页面 controller provider
final popularControllerProvider =
    NotifierProvider<PopularController, PopularState>(PopularController.new);

