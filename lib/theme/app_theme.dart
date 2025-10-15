import 'package:flutter/material.dart';
import 'text_theme.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      bodyMedium: const TextStyle(
        fontSize: 16.0,
        color: Colors.black87,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
  );
}
