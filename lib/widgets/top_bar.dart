import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../features/term/bloc/term_bloc.dart';

class TopBar extends StatelessWidget with PreferredSizeWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // backgroundColor: Colors.white,
      title: Row(
        children: [
          TextButton(
            onPressed: () {
              context.read<TermBloc>().add(const TermChooseFiles());
            },
            child: const Text('Файл'),
          ),
          const Expanded(child: SizedBox()),
          IconButton(
            onPressed: () => Get.changeThemeMode(ThemeMode.light),
            icon: const Icon(Icons.light_mode),
          ),
          IconButton(
            onPressed: () => Get.changeThemeMode(ThemeMode.dark),
            icon: const Icon(Icons.dark_mode, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
