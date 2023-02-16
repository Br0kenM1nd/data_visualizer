import 'package:get/get.dart';

import '../../features/term/model/term.dart';
import '../chart/term_controller.dart';

class DateListController extends GetxController {
  late RxList<Term> terms;

  void setTerms(List<Term> allTerms) => terms = allTerms.obs;

  void updateTermAtIndex(Term term, i) {
    Get.find<TermController>().terms[i] = term;
  }
}