import 'package:get/get.dart';

import '../../features/term/model/las.dart';
import '../../features/term/model/term.dart';
import '../chart/term_controller.dart';

class DateListController extends GetxController {

  RxList<Las> list = RxList<Las>();

  late RxList<Term> temp;
  void updateTerms() {
    temp = Get.find<TermController>().terms;
    temp.assignAll(temp.where((term) => term.show == true).toList());
    print(
      '${("-" * 100).toString()}\n'
          '${'aaaaa'}\n'
          '${("-" * 100).toString()}\n',
    );
  }
}