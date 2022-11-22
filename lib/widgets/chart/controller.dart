import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TermController extends GetxController {
  final zoom = ZoomPanBehavior(
    enableSelectionZooming: true,
    enablePinching: true,
    enableMouseWheelZooming: true,
  );

  void zoomReset() => zoom.reset();
}
