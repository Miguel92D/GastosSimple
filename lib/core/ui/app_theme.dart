/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
library;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_gradients.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get brandTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryPurple,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        secondary: Color(0xFF9A7BFF),
        surface: Color(0xFF16161C),
        error: AppColors.expenseRed,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.cardTitle.copyWith(fontSize: 20),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.titleLarge,
        headlineMedium: AppTextStyles.balanceAmount,
        titleLarge: AppTextStyles.cardTitle,
        bodyLarge: AppTextStyles.bodyMain,
        bodyMedium: AppTextStyles.bodySmall,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16161C),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: Colors.white24,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      primaryColor: AppColors.primaryPurple,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        secondary: const Color(0xFF8B5CF6),
        surface: Colors.white,
        error: AppColors.expenseRed,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: AppTextStyles.cardTitle.copyWith(fontSize: 20, color: Colors.black87),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.titleLarge,
        headlineMedium: AppTextStyles.balanceAmount,
        titleLarge: AppTextStyles.cardTitle,
        bodyLarge: AppTextStyles.bodyMain,
        bodyMedium: AppTextStyles.bodySmall,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }

  // Legacy support for getter name if needed
  static ThemeData get neonTheme => brandTheme;

  // New shared decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: AppColors.cardBorder),
    gradient: AppGradients.glassGradient,
  );
}

