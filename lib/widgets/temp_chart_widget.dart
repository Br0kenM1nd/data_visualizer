import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/data/bloc/data_bloc.dart';

class TempChartWidget extends StatelessWidget {
  const TempChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: BlocBuilder<DataBloc, DataState>(
          builder: (context, state) {
            if (state is DataParsed) {
              return _TempChar(points: state.data[DataType.points]);
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
            spots: points,
          ),
        ],
        minY: 10,
        maxY: 40,
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}
