import 'package:flutter/material.dart';

import '../widgets/calendar/calendar_widget.dart';
import '../widgets/chart/term_widget.dart';
import '../widgets/date_list/date_list_widget.dart';
import '../widgets/top_bar.dart';

class const HomePage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TermWidget(),
          SingleChildScrollView(
            child: Column(
              children: [
                CalendarWidget(),
                Row(children: [DateListWidget()]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
