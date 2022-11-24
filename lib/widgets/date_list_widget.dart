import 'package:data_visualizer/features/term/model/las.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/term/bloc/term_bloc.dart';

class DateListWidget extends StatelessWidget {
  const DateListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermBloc, TermState>(
      builder: (context, state) {
        if (state is TermParsed) {
          final values = RangeValues(0, .9); //state.points.length.toDouble());
          return Row(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: RangeSlider(
                  divisions:
                      state.points.isNotEmpty ? state.points.length : null,
                  values: values,
                  onChanged: (_) {},
                ),
              ),
              Column(
                children: [
                  if (state.list.isNotEmpty) ...[
                    Text('кол-во: ${state.points.length}'),
                    const Text('Дата и время'),
                    for (int i = 0; i < state.list.length; i++)
                      if (state.list[i] is Las)
                        TextButton(
                          onPressed: () {
                            // hide line
                          },
                          child:
                              Text((state.list[i] as Las).dateTime.toString()),
                        ),
                  ],
                ],
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
