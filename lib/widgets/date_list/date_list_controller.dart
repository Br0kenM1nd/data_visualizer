import 'package:get/get.dart';

import '../../features/term/presentation/controllers/term_controller.dart';

class DateListController extends GetxController {
  DateListController({TermController? termController})
    : _termController = termController ?? Get.find<TermController>();

  final TermController _termController;

  void filterTermsByIndexRange(int startIndex, int endIndex) =>
      _termController.filterTermsByIndexRange(startIndex, endIndex);

  void toggleTermVisibility(int index) =>
      _termController.toggleVisibility(index);

  void toggleAllDayThermograms() => _termController.toggleAllDayThermograms();
}
