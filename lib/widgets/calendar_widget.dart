import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/term/bloc/term_bloc.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 200,
        maxWidth: 300,
      ),
      child: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        onDateChanged: (date) {
          context.read<TermBloc>().add(TermChooseDate(date));
        },
      ),
    );
  }
}
