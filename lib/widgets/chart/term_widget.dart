import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../features/term/bloc/term_bloc.dart';
import 'term_controller.dart';

class TermWidget extends StatefulWidget {
  const TermWidget({Key? key}) : super(key: key);

  @override
  State<TermWidget> createState() => _TermWidgetState();
}

class _TermWidgetState extends State<TermWidget> {
  late final TermController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TermController());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermBloc, TermState>(
      builder: (context, state) {
        if (state is TermGot) {
          controller.setTerms(state.terms);
          return Expanded(
            child: GestureDetector(
              onTap: controller.zoomReset,
              child: Obx(
                () => SfCartesianChart(
                  series: controller.terms
                      .map((term) => FastLineSeries(
                            // animationDuration: 0,
                            dataSource: term.points,
                            xValueMapper: (point, step) => term.show ? point.x : 0,
                            yValueMapper: (point, step) => term.show ? point.y : 0,
                            width: 2,
                            // markerSettings: const MarkerSettings(
                            //   isVisible: true,
                            //   height: 4,
                            //   width: 4,
                            //   // shape: DataMarkerType.circle,
                            //   borderWidth: 3,
                            //   // borderColor: Colors.red,
                            // ),
                            dataLabelSettings: const DataLabelSettings(),
                          ))
                      .toList(),
                  primaryXAxis:
                      NumericAxis(title: AxisTitle(text: 'Расстояние, М')),
                  primaryYAxis:
                      NumericAxis(title: AxisTitle(text: 'Температура, °С')),
                  zoomPanBehavior: controller.zoom,
                ),
              ),
            ),
          );
        } else {
          return const EmptyChart();
        }
      },
    );
  }
}

class EmptyChart extends StatelessWidget {
  const EmptyChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SfCartesianChart(
        primaryXAxis: NumericAxis(title: AxisTitle(text: 'Расстояние, М')),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Температура, °С')),
      ),
    );
  }
}
