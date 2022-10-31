import 'package:data_visualizer/features/data/repository/las_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'parser_repository_impl.mocks.dart';

@GenerateMocks([LasParser])
void main() {
  late final LasParser repository;
  late final LasParser realParser;

  setUpAll(() {
    repository = MockParserRepositoryImpl();
    realParser = const LasParser();
  });

  test('Parse term names', () {
    // arrange
    const fakeNames = <String>[];
    const result = FilePickerResult([]);
    when(repository.getNames(result)).thenReturn(fakeNames);

    // act
    final names = repository.getNames(result);

    // verify
    expect(names, fakeNames);
  });

  test('Parse term date times', () async {
    // arrange
    // final res = FilePickerResult();
    const fakeDateTimes = <DateTime>[];
    const result = FilePickerResult([]);
    when(repository.getTimes(result)).thenReturn(fakeDateTimes);

    // act
    final dateTimes = repository.getTimes(result);

    // verify
    expect(dateTimes, fakeDateTimes);
  });

  test('Parse dates from data', () {
    // arrange
    final formattedString =
        realParser.formatString('17.10.2022 11-26-55 averaged.las');
    final date = DateTime.parse(formattedString);
    print(
      '${("-" * 100).toString()}\n'
      '${date.toString()}'
      '\n${("-" * 100).toString()}\n',
    );
    // act

    // verify
    // verify();
  });
}
