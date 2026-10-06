/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius and GlassCard.
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

  /// Título de una fila de lista (`AppListRow`): 14 negrita.
  static const rowTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Subtítulo de una fila de lista (`AppListRow`): 12 gris.
  static const rowSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.softTextDim,
    letterSpacing: 0.2,
  );

  /// Título de pantalla en la barra de arriba (24).
  static const screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  /// Titular grande dentro de una pantalla (Respaldo, Consentimiento,
  /// aviso Pro) (24).
  static const headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Monto destacado en una tarjeta ("Podés gastar hoy", total de
  /// Estadísticas) (26).
  static const amountHighlight = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  /// Monto grande de un resumen (total ahorrado en Metas) (36).
  static const amountHero = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.incomeGreen,
    letterSpacing: -0.5,
  );

  /// Monto que se escribe en "Agregar movimiento" (42).
  static const amountInput = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  /// Precio de Pro (30).
  static const price = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: AppColors.primaryPurple,
    letterSpacing: -1.0,
  );

  /// Número del teclado del PIN (24).
  static const pinDigit = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryPurple,
  );

  /// Etiqueta mínima en MAYÚSCULAS (10): nombre de categoría en su
  /// botón, "MEJOR VALOR".
  static const badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    color: AppColors.softText,
    letterSpacing: 0.2,
  );

  /// Emoji grande para elegir (ícono de una meta).
  static const emoji = TextStyle(fontSize: 24);

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
