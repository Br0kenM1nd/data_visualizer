import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/logger/logger.dart';
import 'parser.dart';

class LasParser implements Parser {
  const LasParser();

  @override
  List<String> getNames(List<File> files) {
    return files
        .map((file) => file.path.split(Platform.pathSeparator).last)
        .toList(growable: false);
  }

  @override
  List<DateTime> getTimes(List<File> files) {
    final names = getNames(files);
    return names
        .map((name) {
          final formatted = formatString(name);
          final parsed = DateTime.tryParse(formatted);
          if (parsed == null) {
            appLogger.w('Unable to parse datetime from file name: $name');
            return DateTime.fromMillisecondsSinceEpoch(0);
          }
          return parsed;
        })
        .toList(growable: false);
  }

  @override
  Future<List<List<Point<double>>>> getPoints(List<File> files) async {
    final paths = files.map((file) => file.path).toList(growable: false);

    final rawData = await Isolate.run(() => _parsePointsByPaths(paths));

    return rawData
        .map(
          (series) => series
              .map((pair) => Point<double>(pair[0], pair[1]))
              .toList(growable: false),
        )
        .toList(growable: false);
  }

  @visibleForTesting
  String formatString(String raw) {
    final normalized = raw.replaceFirst('.las', '').replaceFirst('.csv', '');
    final parts = normalized.split(' ');
    if (parts.length < 2) {
      return '';
    }

    final dateRaw = parts.first.split('.');
    if (dateRaw.length != 3) {
      return '';
    }

    final date = dateRaw.reversed.join('-');
    final time = parts[1].replaceAll('-', ':');
    return '${date}T$time';
  }
}

List<List<List<double>>> _parsePointsByPaths(List<String> paths) {
  return paths.map((path) => _parseSingleFile(path)).toList(growable: false);
}

List<List<double>> _parseSingleFile(String path) {
  final lines = File(path).readAsLinesSync();
  var dataStarted = false;
  final parsed = <List<double>>[];

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }

    if (!dataStarted) {
      if (line == '~A') {
        dataStarted = true;
      }
      continue;
    }

    final pair = _pointFromLine(line);
    if (pair != null) {
      parsed.add(pair);
    }
  }

  return parsed;
}

List<double>? _pointFromLine(String line) {
  final segments = line.split(RegExp(r'\s+'));
  if (segments.length < 2) {
    return null;
  }

  final x = double.tryParse(segments.first.replaceAll(',', '.'));
  final y = double.tryParse(segments.last.replaceAll(',', '.'));
  if (x == null || y == null) {
    return null;
  }

  return <double>[x, y];
}
