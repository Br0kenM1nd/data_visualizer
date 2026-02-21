import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'features/term/data/repositories/term_repository_impl.dart';
import 'features/term/domain/use_cases/get_terms_by_date_use_case.dart';
import 'features/term/domain/use_cases/get_terms_by_range_use_case.dart';
import 'features/term/domain/use_cases/load_last_directory_terms_use_case.dart';
import 'features/term/domain/use_cases/load_terms_use_case.dart';
import 'features/term/presentation/controllers/term_controller.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const repository = TermRepositoryImpl();

  Get.put<TermController>(
    TermController(
      loadTermsUseCase: LoadTermsUseCase(repository: repository),
      loadLastDirectoryTermsUseCase: LoadLastDirectoryTermsUseCase(
        repository: repository,
      ),
      getTermsByDateUseCase: GetTermsByDateUseCase(repository: repository),
      getTermsByRangeUseCase: GetTermsByRangeUseCase(repository: repository),
    ),
    permanent: true,
  );

  unawaited(Get.find<TermController>().restoreLastDirectoryTerms());

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      debugShowCheckedModeBanner: false,
      title: 'Data visualizer',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        colorScheme: const ColorScheme.light(),
      ),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
      home: const HomePage(),
    );
  }
}
