import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Neon)
  static const primaryStart = Color(0xFF6A5AE0); // Deep Purple
  static const primaryEnd = Color(0xFF9F7AEA); // Light Purple
  static const neonCyan = Color(0xFF00F2FF); // Cyan Glow
  static const neonPurple = Color(0xFFB066FE); // Purple Glow

  // Backgrounds
  static const background = Color(0xFF0E0E13);
  static const cardBackground = Color(0xFF1C1C23);
  static const glassBase = Color(0xFF1E1E26);

  // States
  static const income = Color(0xFF4ADE80); // Neon Green
  static const expense = Color(0xFFF87171); // Neon Red
  static const info = Color(0xFF3B82F6); // Neon Blue

  // Text
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF8E8E93);
  static const textMuted = Color(0xFF636366);

  static const primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const neonGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
