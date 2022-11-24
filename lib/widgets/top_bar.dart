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
          IconButton(
            onPressed: () => Get.changeTheme(
                Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
              ),
            icon: Icon(
              Get.isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
