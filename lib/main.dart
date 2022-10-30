import 'package:bloc/bloc.dart';
import 'package:data_visualizer/core/observer.dart';
import 'package:data_visualizer/features/explorer/bloc/explorer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        BlocProvider<ExplorerBloc>(create: (_) => ExplorerBloc()),
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
