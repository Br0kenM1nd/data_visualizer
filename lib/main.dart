import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/observer.dart';
import 'features/data/bloc/data_bloc.dart';
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
        BlocProvider<DataBloc>(create: (_) => DataBloc()),
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
