import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/term/bloc/term_bloc.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/chart/term_chart.dart';
import '../widgets/date_list_widget.dart';
import '../widgets/top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<TermBloc, TermState>(
            builder: (context, state) {
              if (state is TermParsed) {
                return TermChart(termsPoints: state.points);
              } else {
                return const TermChart();
              }
            },
          ),
          // const TempChartWidget(),
          SingleChildScrollView(
            child: Column(
              children: [
                CalendarWidget(),
                Row(
                  children: [
                    DateListWidget(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


