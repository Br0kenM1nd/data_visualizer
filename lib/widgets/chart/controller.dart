import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class ChartController extends GetxController {
  double? x;
  double? y;

  void resolver(FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlTapUpEvent) {
      _getStartCoordinates(response);
    } if (event is FlPanStartEvent) {
      _getStartCoordinates(response);
      // print(
      //   '${("-" * 100).toString()}\n'
      //       'FlPanStartEvent'
      //       '${event.details.localPosition.toString()}'
      //       '\n${("-" * 100).toString()}\n',
      // );
    } if (event is FlPanEndEvent) {
      // print(
      // '${("-" * 100).toString()}\n'
      // 'FlPanEndEvent ${event.details.}'
      // '\n${("-" * 100).toString()}\n',
      // );
    }
  }

  void _getStartCoordinates(LineTouchResponse? response) {
    if (response == null || response.lineBarSpots == null) return;
    // print(response.lineBarSpots!.first.x);
    print(response.lineBarSpots!.first.distance);
    print(response.lineBarSpots!.first.x);
    print(response.lineBarSpots!.first.y);
  }
}