import 'package:flutter/material.dart';

class AppTextTheme {
  static final light = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.indigo,
    ),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
  );

  static final dark = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
  );
}
