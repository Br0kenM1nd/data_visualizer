import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../features/term/bloc/term_bloc.dart';
import '../../features/term/model/las.dart';
import '../../features/term/model/term.dart';
import 'date_list_controller.dart';

class DateListWidget extends StatefulWidget {
  const DateListWidget({Key? key}) : super(key: key);

  @override
  State<DateListWidget> createState() => _DateListWidgetState();
}

class _DateListWidgetState extends State<DateListWidget> {
  late final DateListController controller;

  double rangeEnd(List<Term> terms) {
    var activeTerms = terms.where((term) => term.show).length;
    return activeTerms / terms.length;
  }

  double _minValue = 0;
  late double _maxValue;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DateListController());
    return BlocBuilder<TermBloc, TermState>(
      builder: (context, state) {
        if (state is TermGot && state.terms.isNotEmpty) {
          final terms = state.terms;
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: terms.length * 30,
                ),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: RangeSlider(
                    divisions: terms.isNotEmpty ? terms.length : null,
                    values: RangeValues(_minValue, _maxValue),
                    min: 0,
                    max: terms.length.toDouble(),
                    onChanged: (range) {
                      setState(() {
                        _minValue = range.start;
                        _maxValue = range.end;
                        // for (int i = 0; i < _minValue; i++) {
                        //   terms[i] = terms[i].change();
                        // }
                        // for (int i = terms.length - 1; i > _maxValue; i--) {
                        //   terms[i] = terms[i].change();
                        // }
                      });
                    },
                  ),
                ),
              ),
              Column(
                children: [
                  if (terms.isNotEmpty) ...[
                    Text('кол-во: ${terms.length}'),
                    const Text('Дата и время'),
                    for (int i = 0; i < terms.length; i++)
                      if (terms[i] is Las)
                        TextButton(
                          onPressed: () => setState(() {
                            terms[i] = terms[i].copyWith(show: !terms[i].show);
                            controller.updateTermAtIndex(terms[i], i);
                            // terms.removeAt(i);
                          }),
                          child: Text(
                            (terms[i] as Las).dateTime.toString(),
                            style: TextStyle(
                              // color: terms[i].show
                              //     ? Colors.white
                              //     : Colors.black,
                              decoration: terms[i].show
                                  ? null
                                  : TextDecoration.lineThrough,
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
