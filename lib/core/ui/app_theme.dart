/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius and GlassCard.
library;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
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
        secondary: AppColors.primaryPurpleLight,
        surface: AppColors.surface,
        error: AppColors.expenseRed,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.titleMain,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        contentTextStyle: AppTextStyles.bodyText.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.titleLarge,
        headlineMedium: AppTextStyles.balanceAmount,
        titleLarge: AppTextStyles.cardTitle,
        bodyLarge: AppTextStyles.bodyMain,
        bodyMedium: AppTextStyles.bodySmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      // ── Lo de Material, configurado una vez (R-6, chat 08) ──
      // Diálogos: todos iguales (fondo surface con borde fino, radio lg).
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        titleTextStyle: AppTextStyles.titleSmall,
        contentTextStyle: AppTextStyles.bodyMain,
      ),
      // Botones de texto (diálogos): violetas, como están escritos.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
        ),
      ),
      // Interruptores: prendido violeta con bolita blanca; apagado vidrio.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.softText,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primaryPurple
              : AppColors.glassSurface,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.cardBorder,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primaryPurple
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.textPrimary),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryPurple,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
}
