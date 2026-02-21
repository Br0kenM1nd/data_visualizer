import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    colors: false,
    dateTimeFormat: DateTimeFormat.dateAndTime,
    noBoxingByDefault: true,
    printEmojis: false,
  ),
  output: _CustomOutput(),
);

class _CustomOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (kReleaseMode) return;
    final chunk = event.lines.join('\n');
    log(chunk);
  }
}
