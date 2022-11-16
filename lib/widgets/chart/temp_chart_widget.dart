import 'package:data_visualizer/features/term/model/term.dart';
import 'package:data_visualizer/widgets/chart/controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../features/term/bloc/term_bloc.dart';

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
    final controller = Get.put(ChartController());
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
          touchCallback: controller.resolver,
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
        ),
        borderData: FlBorderData(),
        gridData: FlGridData(drawHorizontalLine: true),
        lineBarsData: [
          if (listData != null)
            for (int i = 0; i < listData!.length; i++)
              LineChartBarData(
                color: Colors.red,
                dotData: FlDotData(show: false),
                spots: listData![i].spots,
              ),
        ],
        minX: null,
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}
