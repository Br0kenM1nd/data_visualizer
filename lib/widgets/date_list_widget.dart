import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/data/bloc/data_bloc.dart';

class DateListWidget extends StatelessWidget {
  const DateListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      builder: (context, state) {
        if (state is DataParsed) {
          return Column(
            children: [
              const Text('Дата и время'),
              ...(state.data[DataType.times] as List<DateTime>).map((dateTime) {
                return Text(dateTime.toString());
              }),

            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
