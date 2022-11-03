import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      providers: [
        BlocProvider<TermBloc>(create: (_) => TermBloc()),
      ],
      child: MaterialApp(
        title: 'Data visualizer',
        theme: ThemeData(
          // primarySwatch: Colors.blue,
          colorScheme: const ColorScheme.dark(),
        ),
        home: const HomePage(),
      ),
    );
  }
}
