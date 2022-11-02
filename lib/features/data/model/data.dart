import 'package:data_visualizer/features/data/model/las.dart';
import 'package:fl_chart/fl_chart.dart';

enum DataType { name, points, dateTime }

enum ResultType { lasTerm, svgTerm, svgRefl }

typedef DataStruct = Map<DataType, dynamic>;

class Data {
  Data();

  late final String name;
  late final List<FlSpot> points;

  factory Data.create({required ResultType type, required DataStruct data}) {
    switch (type) {
      case ResultType.lasTerm:
        return Las(
          name: data[DataType.name],
          points: data[DataType.points],
          dateTime: data[DataType.dateTime],
        );
      case ResultType.svgTerm:
        return Data();
      case ResultType.svgRefl:
        return Data();
    }
  }
}
