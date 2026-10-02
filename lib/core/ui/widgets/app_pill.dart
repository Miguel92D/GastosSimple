/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
library;
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Pill / chip oficial de $imple. Usar SIEMPRE este widget en lugar de
/// armar pills a mano en cada pantalla.
///
/// Medidas fijas: alto 32, padding horizontal 16 (AppSpacing.md),
/// totalmente redonda, texto `subtitle` w700 (12).
///
/// Tres modos:
/// - Informativa (`selected == null`): etiqueta sin interacción
///   (ej: mes en BalanceCard). Con `onColoredSurface: true` usa blanco al 15%.
/// - Seleccionable activa (`selected == true`): fondo `activeColor`
///   (por defecto primaryPurple).
/// - Seleccionable inactiva (`selected == false`): glassSurface + borde cardBorder.
///
/// Si tiene `onTap`, la zona táctil es de 48px de alto (32 visibles + 8 arriba
/// y abajo), así que en una fila ocupa 48 de alto.
class AppPill extends StatelessWidget {
  static const double height = 32;
  static const double tapHeight = 48;

  final String label;
  final bool? selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? activeColor;
  final bool onColoredSurface;

  const AppPill({
    super.key,
    required this.label,
    this.selected,
    this.onTap,
    this.icon,
    this.activeColor,
    this.onColoredSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = selected == true;
    final bool isInfo = selected == null;

    final Color background = isActive
        ? (activeColor ?? AppColors.primaryPurple)
        : isInfo && onColoredSurface
        ? AppColors.textPrimary.withValues(alpha: 0.15)
        : AppColors.glassSurface;

    final Color foreground = isActive || onColoredSurface
        ? AppColors.textPrimary
        : AppColors.softText;

    final BorderSide side = selected == false
        ? const BorderSide(color: AppColors.cardBorder)
        : BorderSide.none;

    final Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: ShapeDecoration(
        color: background,
        shape: StadiumBorder(side: side),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subtitle.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: pill,
        ),
      ),
    );
  }
}
