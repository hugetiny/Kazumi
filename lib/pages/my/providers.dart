import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_controller.dart';

final collectControllerProvider =
    NotifierProvider<CollectController, CollectState>(CollectController.new);
