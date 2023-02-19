import 'dart:io';
import 'dart:math';

abstract class Parser {
  List<String?> getNames(List<File> files);

  List<List<Point>?> getPoints(List<File> files);

  List<DateTime> getTimes(List<File> files);
}
