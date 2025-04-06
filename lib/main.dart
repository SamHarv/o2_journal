import 'package:flutter/material.dart';

import '/config/constants.dart';
import 'ui/views/home_view.dart';

void main() => runApp(const O2Journal());

class O2Journal extends StatelessWidget {
  const O2Journal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O2 Journal',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: white)),
      home: const HomeView(),
    );
  }
}
