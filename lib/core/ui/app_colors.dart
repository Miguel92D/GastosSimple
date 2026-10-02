/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
library;
import 'package:flutter/material.dart';

class AppColors {
  // Brand Identity (Violet/Purple)
  static const primaryPurple = Color(0xFF7B5CFF);
  static const primaryDeep = Color(0xFF6F4DFF); // inicio del gradiente de marca
  static const primaryLight = Color(0xFF9A7BFF); // fin del gradiente de marca

  // States (Neon/Minimal)
  static const incomeGreen = Color(0xFF3DDC97);
  static const expenseRed = Color(0xFFFF5C5C);

  // Backdrop & Surfaces
  static const darkBackground = Color(0xFF0E0E11);
  static const glassSurface = Color(
    0x1AFFFFFF,
  ); // Low opacity white for glass base
  static const surface = Color(0xFF16161C); // superficie sólida (cards de Material, sheets)

  // Typography
  static const textPrimary = Colors.white;
  static const softText = Color(0xFFBFBFD2);
  static const textMuted = Color(0xFF636366);

  // UI Accents
  static const cardBorder = Color(0x33FFFFFF);
  static const shadowPurple = Color(
    0x4D7B5CFF,
  ); // 30% opacity purple for shadows

  // Pro / Premium (usar SOLO para elementos Pro)
  static const gold = Color(0xFFD4AF37); // dorado metálico
  static const goldShine = Color(0xE6FFFACD); // brillo del shimmer (90%)

  // Category Colors (Premium/Neon)
  static const orange = Color(0xFFFB923C);
  static const blue = Color(0xFF60A5FA);
  static const indigo = Color(0xFF818CF8);
  static const teal = Color(0xFF2DD4BF);
  static const pink = Color(0xFFFB7185);
  static const purple = Color(0xFFC084FC);
  static const amber = Color(0xFFFBBF24); // tips, gráficos
  static const sky = Color(0xFF38BDF8); // gráficos
  static const violet = Color(0xFF6366F1); // gráficos

  // Legacy / Compatibility Helpers
  // (Optional: keep aliases for existing code until fully refactored if needed)
  static const income = incomeGreen;
  static const expense = expenseRed;
  static const background = darkBackground;
}
