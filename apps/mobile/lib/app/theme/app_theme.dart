import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    appBarTheme: const AppBarTheme(centerTitle: true),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );
}
