import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_visualizer/features/explorer/model/point.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

FlSpot pointFromLine(String line) {
  final distTemp = line.split(' ');
  return FlSpot(double.parse(distTemp.first), double.parse(distTemp.last));
}

class ExplorerRepository {
  const ExplorerRepository();

  Future<FilePickerResult?> pickFiles() {
    return FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['las'],
      withReadStream: true,
    );
  }

  List<FlSpot> getTempFromFiles(FilePickerResult result) {
    final files = result.paths.map((file) => File(file!)).toList();
    final names = result.names;
    List<FlSpot> points = [];
    final temps = files.map((file) {
      return parseTemp(prepareStrings(file.readAsStringSync()));
    }).toList();
    final mapTemps = Map.fromIterables(names, temps);
    print(
      '${("-" * 100).toString()}\n'
          '${names}'
          '\n${("-" * 100).toString()}\n',
    );
    // fileStream
    //     .listen((bytes) => buffer.write(String.fromCharCodes(bytes)))
    //     .onDone(() => completer.complete(parseTemp(prepareStrings(buffer))));
    // print(await completer.future);
    // return completer.future;
    return temps.expand((element) => element).toList();
  }

  @visibleForTesting
  List<String> prepareStrings(String raw) {
    final data = raw.toString().split('~A');
    return const LineSplitter().convert(data[1])..removeAt(0);
  }

  @visibleForTesting
  List<FlSpot> parseTemp(List<String> lines) {
    return lines.map((line) => pointFromLine(line)).toList();
  }
}
