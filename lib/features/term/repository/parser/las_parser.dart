import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../source/data_source.dart';
import 'parser.dart';

Point pointFromLine(String line) {
  final distTemp = line.split(' ');
  return Point(double.parse(distTemp.first), double.parse(distTemp.last));
}

class LasParser implements Parser {
  final DataSource source;

  const LasParser({this.source = const DataSource()});

  @override
  List<String?> getNames(List<File> files) {
    return files.map((file) => file.uri.pathSegments.last).toList();
  }

  @override
  List<DateTime> getTimes(List<File> files) {
    final names = getNames(files);
    return names.map((name) => DateTime.parse(formatString(name!))).toList();
  }

  @visibleForTesting
  String formatString(String raw) {
    raw = raw.replaceFirst('.las', '');
    raw = raw.replaceFirst('.csv', '');
    final strings = raw.split(' ');
    final dateRaw = strings[0].split('.');
    final date = dateRaw.reversed.join('-');
    final time = strings[1].replaceAll('-', ':');
    final dateAndTime = List.from([date, time]);
    final string = dateAndTime.join('T');
    return string;
  }

  @override
  List<List<Point>?> getPoints(List<File> files) {
    return getPointsFromFiles(files);
  }

  @visibleForTesting
  List<List<Point>> getPointsFromFiles(List<File> files) {
    return files.map((file) {
      return parsePoints(removeLasHeader(file.readAsStringSync()));
    }).toList();
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
}
