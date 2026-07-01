import 'dart:math';

class TermChartDataSampler {
  const new _();

  static List<Point<double>> sample(
    List<Point<double>> points, {
    required double? visibleMin,
    required double? visibleMax,
    required int targetPointCount,
  }) {
    if (points.isEmpty || targetPointCount <= 0) {
      return const <Point<double>>[];
    }

    final ranged = _visiblePoints(points, visibleMin: visibleMin, visibleMax: visibleMax);
    if (ranged.length <= targetPointCount) {
      return ranged;
    }

    final bucketCount = max(1, targetPointCount ~/ 2);
    final bucketSize = ranged.length / bucketCount;
    final sampled = <Point<double>>[];

    for (var bucketIndex = 0; bucketIndex < bucketCount; bucketIndex++) {
      final start = (bucketIndex * bucketSize).floor();
      final end = min(ranged.length, ((bucketIndex + 1) * bucketSize).floor());
      if (start >= end) {
        continue;
      }

      var minIndex = start;
      var maxIndex = start;
      for (var i = start + 1; i < end; i++) {
        if (ranged[i].y < ranged[minIndex].y) {
          minIndex = i;
        }
        if (ranged[i].y > ranged[maxIndex].y) {
          maxIndex = i;
        }
      }

      if (minIndex <= maxIndex) {
        sampled.add(ranged[minIndex]);
        if (maxIndex != minIndex) {
          sampled.add(ranged[maxIndex]);
        }
      } else {
        sampled
          ..add(ranged[maxIndex])
          ..add(ranged[minIndex]);
      }
    }

    return sampled;
  }

  static List<Point<double>> _visiblePoints(
    List<Point<double>> points, {
    required double? visibleMin,
    required double? visibleMax,
  }) {
    if (visibleMin == null || visibleMax == null || visibleMin >= visibleMax) {
      return points;
    }

    return points
        .where((point) => point.x >= visibleMin && point.x <= visibleMax)
        .toList(growable: false);
  }
}
