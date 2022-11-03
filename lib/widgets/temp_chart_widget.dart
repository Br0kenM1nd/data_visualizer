import 'package:data_visualizer/features/term/model/term.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/term/bloc/term_bloc.dart';

class TempChartWidget extends StatelessWidget {
  const TempChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: BlocBuilder<TermBloc, TermState>(
          builder: (context, state) {
            if (state is TermParsed) {
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
  final List<Term>? listData;

  const _TempChar({this.listData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          // distanceCalculator: ,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
          touchCallback: resolver,
        ),
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
        minX: null,
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}

void resolver(FlTouchEvent event, LineTouchResponse? response) {
  if (event is FlTapUpEvent) {
    print(
      '${("-" * 100).toString()}\n'
          'FlTapUpEvent'
          '\n${("-" * 100).toString()}\n',
    );
  } if (event is FlPanStartEvent) {
    print(
      '${("-" * 100).toString()}\n'
          'FlPanStartEvent'
          '${event.details.localPosition.toString()}'
          '\n${("-" * 100).toString()}\n',
    );
  } if (event is FlPanEndEvent) {
    print(
      '${("-" * 100).toString()}\n'
          'FlPanEndEvent'
          '\n${("-" * 100).toString()}\n',
    );
  }
}