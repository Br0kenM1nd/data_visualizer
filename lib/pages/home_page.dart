import 'package:flutter/material.dart';

import '../widgets/calendar/calendar_widget.dart';
import '../widgets/chart/term_widget.dart';
import '../widgets/date_list/date_list_widget.dart';
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
          TermWidget(),
          SingleChildScrollView(
            child: Column(
              children: [
                const CalendarWidget(),
                Row(
                  children: const [
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


