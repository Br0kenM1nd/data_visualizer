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
  static const colors = [
    Color.fromRGBO(75, 135, 185, 1),
    Color.fromRGBO(192, 108, 132, 1),
    Color.fromRGBO(246, 114, 128, 1),
    Color.fromRGBO(248, 177, 149, 1),
    Color.fromRGBO(116, 180, 155, 1),
    Color.fromRGBO(0, 168, 181, 1),
    Color.fromRGBO(73, 76, 162, 1),
    Color.fromRGBO(255, 205, 96, 1),
    Color.fromRGBO(255, 240, 219, 1),
    Color.fromRGBO(238, 238, 238, 1)
  ];

  double rangeEnd(List<Term> terms) {
    var activeTerms = terms.where((term) => term.show).length;
    return activeTerms / terms.length;
  }

  double _minValue = 0;
  double _maxValue = 1;

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
                      });
                      for (int i = 0; i < terms.length; i++) {
                        if (_minValue <= i && i < _maxValue) {
                          terms[i] = terms[i].copyWith(show: true);
                          controller.updateTermAtIndex(terms[i], i);
                        } else {
                          terms[i] = terms[i].copyWith(show: false);
                          controller.updateTermAtIndex(terms[i], i);
                        }
                      }
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
                          }),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: colors[i % colors.length],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (terms[i] as Las).dateTime.toString(),
                                style: TextStyle(
                                  color: terms[i].show ? null : Colors.grey,
                                ),
                              ),
                            ],
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
