import 'dart:math';

import 'package:file_picker/file_picker.dart';

abstract class Parser {
  List<String?> getNames(FilePickerResult result);

  List<List<Point>?> getPoints(FilePickerResult result);

  List<DateTime> getTimes(FilePickerResult result);
}
