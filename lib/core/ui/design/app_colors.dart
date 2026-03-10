import 'package:flutter/material.dart';

class AppColors {
  static const primaryStart = Color(0xFF6A5AE0);
  static const primaryEnd = Color(0xFF9F7AEA);
  static const background = Color(0xFF0E0E13);
  static const cardBackground = Color(0xFF1C1C23);
  static const income = Color(0xFF4ADE80);
  static const expense = Color(0xFFF87171);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF8E8E93);

  static const primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
