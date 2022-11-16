import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:data_visualizer/features/term/repository/parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

import 'common/data_source.dart';

FlSpot spotFromLine(String line) {
  final distTemp = line.split(' ');
  return FlSpot(double.parse(distTemp.first), double.parse(distTemp.last));
}

Point pointFromLine(String line) {
  final distTemp = line.split(' ');
  return Point(double.parse(distTemp.first), double.parse(distTemp.last));
}

class LasParser implements Parser {
  final DataSource source;

  const LasParser({this.source = const DataSource()});

  @override
  List<String?> getNames(FilePickerResult result) => result.names;

  @override
  List<DateTime> getTimes(FilePickerResult result) {
    final names = getNames(result);
    return names.map((name) => DateTime.parse(formatString(name!))).toList();
  }

  @visibleForTesting
  String formatString(String raw) {
    final strings = raw.split(' ');
    final dateRaw = strings[0].split('.');
    final date = dateRaw.reversed.join('-');
    final time = strings[1].replaceAll('-', ':');
    final dateAndTime = List.from([date, time]);
    final string = dateAndTime.join('T');
    return string;
  }

  @override
  List<List<FlSpot>?> getSpots(FilePickerResult result) {
    return getSpotsFromFiles(getFiles(result));
  }

  @override
  List<List<Point>?> getPoints(FilePickerResult result) {
    return getPointsFromFiles(getFiles(result));
  }

  @visibleForTesting
  List<List<Point>> getPointsFromFiles(List<File> files) {
    return files.map((file) {
      return parsePoints(removeLasHeader(file.readAsStringSync()));
    }).toList();
  }

  @visibleForTesting
  List<List<FlSpot>> getSpotsFromFiles(List<File> files) {
    return files.map((file) {
      return parseSpots(removeLasHeader(file.readAsStringSync()));
    }).toList();
  }

  @visibleForTesting
  List<File> getFiles(FilePickerResult result) {
    return result.paths.map((file) => File(file!)).toList();
  }

  @visibleForTesting
  List<String> removeLasHeader(String raw) {
    final data = raw.split('~A').last;
    return const LineSplitter().convert(data)..removeAt(0);
  }

  @visibleForTesting
  List<Point> parsePoints(List<String> lines) {
    return lines.map((line) => pointFromLine(line)).toList();
  }

  @visibleForTesting
  List<FlSpot> parseSpots(List<String> lines) {
    return lines.map((line) => spotFromLine(line)).toList();
  }
}
