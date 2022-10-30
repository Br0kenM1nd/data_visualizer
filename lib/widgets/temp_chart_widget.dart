import 'package:data_visualizer/data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/explorer/bloc/explorer_bloc.dart';

class TempChartWidget extends StatelessWidget {
  const TempChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: BlocBuilder<ExplorerBloc, ExplorerState>(
          builder: (context, state) {
            if (state is ExplorerLasOpenSuccessfully) {
              return _TempChar(points: state.points);
            } else {
              return const _TempChar();
            }
          },
        ),
      ),
    );
  }
}

class _TempChar extends StatelessWidget {
  final List<FlSpot>? points;

  const _TempChar({this.points, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
        ),
        borderData: FlBorderData(),
        gridData: FlGridData(drawHorizontalLine: true),
        lineBarsData: [
          LineChartBarData(
            color: Colors.red,
            dotData: FlDotData(show: false),
            spots: points ?? Data.fakePoints,
          ),
        ],
        minY: 10,
        maxY: 40,
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
      // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}
