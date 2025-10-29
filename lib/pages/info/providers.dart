import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/pages/info/info_controller.dart';

final infoControllerProvider =
    NotifierProvider<InfoController, InfoState>(InfoController.new);