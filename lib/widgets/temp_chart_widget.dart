import 'package:data_visualizer/features/data/model/data.dart';
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
              return _TempChar(listData: state.list);
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
  final List<Data>? listData;

  const _TempChar({this.listData, Key? key}) : super(key: key);

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
          // ...data!.map((key, value) => LineChartBarData()).toList(),
          // ...data![DataType.name].map((key, value) => LineChartBarData()).toList(),
          if (listData != null)
            for (int i = 0; i < listData!.length; i++)
              LineChartBarData(
                color: Colors.red,
                dotData: FlDotData(show: false),
                spots: listData![i].points,
              ),
        ],
        // minY: 10,
        // maxY: 40,
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}

// class _LineWidget {
//
//     return LineChartBarData(
//       color: Colors.red,
//       dotData: FlDotData(show: false),
//       spots: points,
//     );
//
// }
