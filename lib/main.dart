import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/observer.dart';
import 'features/term/bloc/term_bloc.dart';
import 'pages/home_page.dart';

void main() {
  Bloc.observer = Observer();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<TermBloc>(create: (_) => TermBloc())],
      child: GetMaterialApp(
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        title: 'Data visualizer',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(color: Colors.white),
          colorScheme: const ColorScheme.light(),
        ),
        darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
        home: const HomePage(),
      ),
    );
  }
}
