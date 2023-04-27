import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/term/model/term.dart';
import '../chart/term_controller.dart';

class DateListController extends GetxController {
  var minValue = 0.0, maxValue = 1.0;
  late var values = RangeValues(minValue, maxValue).obs;

  var terms = <Term>[].obs;

  filterTerms(RangeValues range, List<Term> terms) {
    minValue = range.start;
    maxValue = range.end;
    for (int i = 0; i < terms.length; i++) {
      if (minValue <= i && i < maxValue) {
        terms[i] = terms[i].copyWith(show: true);
        updateTermAtIndex(terms[i], i);
      } else {
        terms[i] = terms[i].copyWith(show: false);
        updateTermAtIndex(terms[i], i);
      }
    }
  }

  void updateTermAtIndex(Term term, i) {
    Get.find<TermController>().terms[i] = term;
  }
}