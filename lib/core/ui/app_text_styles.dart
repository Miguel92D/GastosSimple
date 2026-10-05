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

  static const titleMain = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const balanceAmount = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  /// Monto de la tarjeta de balance del inicio (32). Tamaño FIJO: la
  /// tarjeta mide lo mismo en Día, en Mes y con cualquier monto (D-030).
  static const balanceCardAmount = TextStyle(
    fontSize: 32,
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

  /// Etiqueta chica en MAYÚSCULAS (11): encabezado de tarjetas chicas,
  /// estados y datos secundarios (D-029).
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.softText,
    letterSpacing: 1.0,
  );

  /// Título de tarjeta chica o de panel (18) (D-029).
  static const titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Monto dentro de una lista (15) (D-029).
  static const amountList = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Monto de las tarjetas de Ingresos / Gastos (13). Tamaño FIJO: se ve
  /// igual en todas las pantallas y con cualquier monto (D-030).
  static const amountCard = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.2,
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

  /// Opción de un selector (`AppSegmented`): 13/w800, MAYÚSCULAS.
  static const segmentLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.softText,
    letterSpacing: 0.5,
  );

  /// Texto de `AppSecondaryButton` (14, MAYÚSCULAS).
  static const secondaryButtonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryPurple,
    letterSpacing: 0.5,
  );

  // Helper methods
  static TextStyle title() => cardTitle;
  static TextStyle body() => bodyText;
  static TextStyle balance() => balanceAmount;
}
