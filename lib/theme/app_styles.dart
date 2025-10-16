// theme/app_styles.dart
import 'package:flutter/material.dart';

class AppStyles {
  static final cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static final cardShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static final borderRadius = BorderRadius.circular(12);
  static final borderRadiusSmall = BorderRadius.circular(8);
  static final borderRadiusLarge = BorderRadius.circular(16);
}
