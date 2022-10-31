import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';

abstract class Parser {
  List<String?> getNames(FilePickerResult result);

  List<DateTime> getTimes(FilePickerResult result);

  List<FlSpot>? getPoints(FilePickerResult result);
}
