/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
library;

import 'package:flutter/material.dart';

class AppColors {
  // Brand Identity (Violet/Purple)
  static const primaryPurple = Color(0xFF7B5CFF);

  // States (Neon/Minimal)
  static const incomeGreen = Color(0xFF3DDC97);
  static const expenseRed = Color(0xFFFF5C5C);

  static const primaryPurpleDeep = Color(0xFF6F4DFF);
  static const primaryPurpleLight = Color(0xFF9A7BFF);

  // Pro (Gold) — reservado para elementos Premium
  static const gold = Color(0xFFD4AF37);
  static const goldShine = Color(0xFFFFFACD);

  // Backdrop & Surfaces
  static const darkBackground = Color(0xFF0E0E11);
  static const surface = Color(0xFF16161C);
  static const glassSurface = Color(
    0x1AFFFFFF,
  ); // Low opacity white for glass base

  // Typography
  static const textPrimary = Colors.white;
  static const softText = Color(0xFFBFBFD2);
  static const textMuted = Color(0xFF636366);

  // UI Accents
  /// Fondo oscuro detrás de un "cargando" que tapa la pantalla.
  static const overlay = Color(0x8A000000);
  static const cardBorder = Color(0x33FFFFFF);
  static const shadowPurple = Color(
    0x4D7B5CFF,
  ); // 30% opacity purple for shadows

  // Category Colors (Premium/Neon)
  static const orange = Color(0xFFFB923C);
  static const blue = Color(0xFF60A5FA);
  static const indigo = Color(0xFF818CF8);
  static const teal = Color(0xFF2DD4BF);
  static const pink = Color(0xFFFB7185);
  static const purple = Color(0xFFC084FC);
  static const amber = Color(0xFFFBBF24);
  static const sky = Color(0xFF38BDF8);
  static const violet = Color(0xFF6366F1);

  // Legacy / Compatibility Helpers
  // (Optional: keep aliases for existing code until fully refactored if needed)
  static const income = incomeGreen;
  static const expense = expenseRed;
  static const background = darkBackground;
}
