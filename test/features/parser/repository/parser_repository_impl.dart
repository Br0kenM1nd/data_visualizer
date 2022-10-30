import 'package:data_visualizer/features/parser/repository/parser_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'parser_repository_impl.mocks.dart';

@GenerateMocks([ParserRepositoryImpl])
void main() {
  late final ParserRepositoryImpl repository;
  
  setUp(() => repository = MockParserRepositoryImpl());

  test('Parse term date times', () {
    // arrange
    final fakeNames = <String>[];
    when(repository.getTermNames()).thenReturn(fakeNames);

    // act
    final names = repository.getTermNames();

    // verify
    expect(names, fakeNames);
  });
}