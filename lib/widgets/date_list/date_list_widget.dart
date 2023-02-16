import 'package:data_visualizer/features/term/model/las.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../features/term/bloc/term_bloc.dart';
import 'date_list_controller.dart';

class DateListWidget extends StatefulWidget {
  const DateListWidget({Key? key}) : super(key: key);

  @override
  State<DateListWidget> createState() => _DateListWidgetState();
}

class _DateListWidgetState extends State<DateListWidget> {
  late final DateListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DateListController());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermBloc, TermState>(
      builder: (context, state) {
        if (state is TermGot) {
          final values = RangeValues(0, .9); //state.points.length.toDouble());
          return Row(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: RangeSlider(
                  divisions: state.terms.isNotEmpty ? state.terms.length : null,
                  values: values,
                  onChanged: (_) {},
                ),
              ),
              Column(
                children: [
                  if (state.terms.isNotEmpty) ...[
                    Text('кол-во: ${state.terms.length}'),
                    const Text('Дата и время'),
                    for (int i = 0; i < state.terms.length; i++)
                      if (state.terms[i] is Las)
                        TextButton(
                          onPressed: () => setState(() {
                            state.terms[i] = state.terms[i]
                                .copyWith(show: !state.terms[i].show);
                            controller.updateTermAtIndex(state.terms[i], i);
                            // state.terms.removeAt(i);
                          }),
                          child: Text(
                            (state.terms[i] as Las).dateTime.toString(),
                            style: TextStyle(
                              color: state.terms[i].show
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
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
