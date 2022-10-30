import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/explorer/bloc/explorer_bloc.dart';

class TopBar extends StatelessWidget with PreferredSizeWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          TextButton(
            onPressed: () {
              context.read<ExplorerBloc>().add(const ExplorerFilePressed());
            },
            child: const Text('Файл'),
          ),
        ],
      ),
    );
  }
}
