import 'package:data_visualizer/features/term/domain/use_cases/get_terms_by_date_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/get_terms_by_range_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/load_last_directory_terms_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/load_terms_use_case.dart';
import 'package:data_visualizer/features/term/presentation/controllers/term_controller.dart';
import 'package:data_visualizer/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.put<TermController>(
      TermController(
        loadTermsUseCase: LoadTermsUseCase(),
        loadLastDirectoryTermsUseCase: LoadLastDirectoryTermsUseCase(),
        getTermsByDateUseCase: GetTermsByDateUseCase(),
        getTermsByRangeUseCase: GetTermsByRangeUseCase(),
      ),
    );
  });

  tearDown(Get.reset);

  testWidgets('App renders main controls', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Файл'), findsOneWidget);
  });
}
