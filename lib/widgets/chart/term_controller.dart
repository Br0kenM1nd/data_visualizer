import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../features/term/model/term.dart';

class TermController extends GetxController {
  TermController();

  late RxList<Term> terms;

  void setTerms(List<Term> allTerms) => terms = allTerms.obs;

  final zoom = ZoomPanBehavior(
    enableSelectionZooming: true,
    enablePinching: true,
    enableMouseWheelZooming: true,
  );

  void zoomReset() => zoom.reset();
}
