/**
 * This project uses centralized layout constants.
 * Direct usage of hardcoded spacing values, radius values, or shadow definitions is discouraged.
 * Use AppSpacing, AppRadius, and AppShadows instead.
 */
import 'package:flutter/material.dart';

class AppShadows {
  static const softShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const glassShadow = BoxShadow(
    color: Colors.black38,
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}
