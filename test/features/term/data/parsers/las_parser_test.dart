import 'dart:io';
import 'dart:math';

import 'package:data_visualizer/features/term/data/parsers/las_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LasParser', () {
    late Directory tempDir;
    const parser = LasParser();

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('las_parser_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('formatString converts file names into ISO datetime format', () {
      final formatted = parser.formatString('17.10.2022 11-26-55 averaged.las');

      expect(formatted, equals('2022-10-17T11:26:55'));
    });

    test('getNames/getTimes/getPoints parse LAS file content', () async {
      final file = File('${tempDir.path}/17.10.2022 11-26-55 averaged.las')
        ..writeAsStringSync('~A\n0.00 21.10\n2.00 22.20\n4.00 23.30\n');

      final names = parser.getNames(<File>[file]);
      final times = parser.getTimes(<File>[file]);
      final points = await parser.getPoints(<File>[file]);

      expect(names, equals(<String>['17.10.2022 11-26-55 averaged.las']));
      expect(times, equals(<DateTime>[DateTime(2022, 10, 17, 11, 26, 55)]));
      expect(
        points.single,
        equals(<Point<double>>[
          const Point<double>(0, 21.1),
          const Point<double>(2, 22.2),
          const Point<double>(4, 23.3),
        ]),
      );
    });
  });
}
