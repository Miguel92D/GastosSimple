import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get neonTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryStart,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryStart,
        brightness: Brightness.dark,
        primary: AppColors.primaryStart,
        secondary: AppColors.primaryEnd,
        surface: AppColors.cardBackground,
        error: AppColors.expense,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
    );
  }
}
