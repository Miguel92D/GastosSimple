/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
library;
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Hero / High Impact
  static const titleLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  static const balanceAmount = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  // Content Labels & Cards
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const subLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.softText,
    letterSpacing: 1.0,
  );

  // Typography Foundations
  static const subtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.softText,
    letterSpacing: 0.5,
  );

  static const bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.softText,
  );

  // Semantic Aliases
  static const bodyMain = bodyText;
  static const bodySmall = subtitle;

  static const buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // Categories & States
  static const incomeValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.incomeGreen,
    letterSpacing: -0.5,
  );

  static const expenseValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.expenseRed,
    letterSpacing: -0.5,
  );

  // Helper methods
  static TextStyle title() => cardTitle;
  static TextStyle body() => bodyText;
  static TextStyle balance() => balanceAmount;
}
