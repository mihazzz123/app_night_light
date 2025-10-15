import 'package:flutter/material.dart';
import 'text_theme.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.light,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: AppTextTheme.dark,
  );
}
