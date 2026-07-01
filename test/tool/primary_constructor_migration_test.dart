import 'package:flutter_test/flutter_test.dart';

import '../../tool/primary_constructor_migration.dart';

void main() {
  group('migratePrimaryConstructorsInSource', () {
    test('moves a const field-formal constructor into the class header', () {
      const source = '''
class Term extends Equatable {
  const Term({required this.name, required this.points, this.show = true});

  final String name;
  final List<Point<double>> points;
  final bool show;

  List<Object> get props => <Object>[name, points, show];
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/term.dart');

      expect(result.migratedClasses, contains('Term'));
      expect(result.skippedClasses, isEmpty);
      expect(result.source, '''
class const Term({
  required final String name,
  required final List<Point<double>> points,
  final bool show = true,
}) extends Equatable {
  List<Object> get props => <Object>[name, points, show];
}
''');
    });

    test('moves a super-parameter-only constructor into the class header', () {
      const source = '''
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/top_bar.dart');

      expect(result.migratedClasses, contains('TopBar'));
      expect(result.source, '''
class const TopBar({super.key}) extends StatelessWidget {
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
''');
    });

    test('moves an empty const constructor into the class header', () {
      const source = '''
class DataSource {
  const DataSource();

  Future<void> load() async {}
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/data_source.dart');

      expect(result.migratedClasses, contains('DataSource'));
      expect(result.skippedClasses, isEmpty);
      expect(result.source, '''
class const DataSource() {
  Future<void> load() async {}
}
''');
    });

    test('uses concise new syntax for initializer-list constructors', () {
      const source = '''
class Controller {
  Controller({Service? service}) : _service = service ?? Service();

  final Service _service;
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/controller.dart');

      expect(result.migratedClasses, contains('Controller'));
      expect(result.skippedClasses, isEmpty);
      expect(result.source, '''
class Controller {
  new({Service? service}) : _service = service ?? Service();

  final Service _service;
}
''');
    });

    test('uses concise new syntax for constructors that stay in the body', () {
      const source = '''
class Controller {
  Controller({Service? service}) : _service = service ?? Service();
  const Controller.named(this._service);

  final Service _service;
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/controller.dart');

      expect(result.migratedClasses, contains('Controller'));
      expect(result.skippedClasses, isEmpty);
      expect(result.source, '''
class Controller {
  new({Service? service}) : _service = service ?? Service();
  const new named(this._service);

  final Service _service;
}
''');
    });

    test('uses concise factory syntax for named factory constructors', () {
      const source = '''
class Point {
  const Point(this.x, this.y);
  factory Point.origin() => const Point(0, 0);

  final double x;
  final double y;
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/point.dart');

      expect(result.migratedClasses, contains('Point'));
      expect(result.source, '''
class const Point(
  final double x,
  final double y,
) {
  factory origin() => const Point(0, 0);
}
''');
    });

    test('keeps annotated fields while using concise new syntax', () {
      const source = '''
class Las extends Term implements Dated {
  const Las({required super.name, required this.dateTime});

  @override
  final DateTime dateTime;
}
''';

      final result = migratePrimaryConstructorsInSource(source, path: 'lib/las.dart');

      expect(result.migratedClasses, contains('Las'));
      expect(result.skippedClasses, isEmpty);
      expect(result.source, '''
class Las extends Term implements Dated {
  const new({required super.name, required this.dateTime});

  @override
  final DateTime dateTime;
}
''');
    });
  });
}
