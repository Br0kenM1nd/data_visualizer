import 'package:flutter/material.dart';

import '../widgets/calendar_widget.dart';
import '../widgets/date_list_widget.dart';
import '../widgets/temp_chart_widget.dart';
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
          const TempChartWidget(),
          Column(
            children: [
              const CalendarWidget(),
              Row(
                children: [
                  DateListWidget(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


