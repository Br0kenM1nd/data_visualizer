import 'dart:convert';
import 'dart:io';

import 'package:data_visualizer/features/data/repository/parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

import 'common/data_source.dart';

FlSpot pointFromLine(String line) {
  final distTemp = line.split(' ');
  return FlSpot(double.parse(distTemp.first), double.parse(distTemp.last));
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
    // DateFormat dateFormat = DateFormat('dd-MM-yyyy HH-mm-ss');
    // DateTime dateTime = dateFormat.parse(string);
    return string;
  }

  @override
  List<List<FlSpot>?> getPoints(FilePickerResult result) {
    // final names = getNames(result);
    // final mapTemps = Map.fromIterables(names, temps);
    return getTemps(getFiles(result));
    // return temps.expand((element) => element).toList();
  }

  @visibleForTesting
  List<List<FlSpot>> getTemps(List<File> files) {
    return files.map((file) {
      return parseTemp(removeFileHeader(file.readAsStringSync()));
    }).toList();
  }

  @visibleForTesting
  List<File> getFiles(FilePickerResult result) {
    return result.paths.map((file) => File(file!)).toList();
  }

  @visibleForTesting
  List<String> removeFileHeader(String raw) {
    final data = raw.split('~A').last;
    return const LineSplitter().convert(data)..removeAt(0);
  }

  @visibleForTesting
  List<FlSpot> parseTemp(List<String> lines) {
    return lines.map((line) => pointFromLine(line)).toList();
  }
}
