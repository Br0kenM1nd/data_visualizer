import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 200,
        maxWidth: 300,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        onDateChanged: (_) {},
      ),
    );
  }
}
