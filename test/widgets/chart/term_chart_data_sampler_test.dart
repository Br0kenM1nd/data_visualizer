import 'dart:math';

import 'package:data_visualizer/widgets/chart/term_chart_data_sampler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TermChartDataSampler', () {
    test('keeps points inside the current visible x range', () {
      final points = <Point<double>>[
        const Point<double>(0, 0),
        const Point<double>(1, 10),
        const Point<double>(2, 20),
        const Point<double>(3, 30),
      ];

      final sampled = TermChartDataSampler.sample(
        points,
        visibleMin: 1,
        visibleMax: 2,
        targetPointCount: 100,
      );

      expect(
        sampled,
        equals(<Point<double>>[const Point<double>(1, 10), const Point<double>(2, 20)]),
      );
    });

    test('preserves min and max y values for each bucket when reducing points', () {
      final points = <Point<double>>[
        const Point<double>(0, 0),
        const Point<double>(1, 10),
        const Point<double>(2, -10),
        const Point<double>(3, 1),
        const Point<double>(4, 20),
        const Point<double>(5, -20),
        const Point<double>(6, 2),
        const Point<double>(7, 0),
      ];

      final sampled = TermChartDataSampler.sample(
        points,
        visibleMin: 1,
        visibleMax: 6,
        targetPointCount: 4,
      );

      expect(
        sampled,
        equals(<Point<double>>[
          const Point<double>(1, 10),
          const Point<double>(2, -10),
          const Point<double>(4, 20),
          const Point<double>(5, -20),
        ]),
      );
    });
  });
}
