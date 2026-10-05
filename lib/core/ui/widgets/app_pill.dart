import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Pill oficial de $imple (skill `diseno-simple`, P-20).
///
/// - Informativa (`selected: null`): fondo vidrio, texto suave.
///   Con [onColoredSurface] va blanca al 15% sobre una tarjeta de color.
/// - Activa (`selected: true`): fondo [activeColor], texto blanco.
/// - Inactiva (`selected: false`): vidrio con borde, texto suave.
///
/// Alto visible 32. Con [onTap] suma 8 arriba y abajo: zona táctil de 48.
class AppPill extends StatelessWidget {
  static const double height = 32;

  final String label;
  final bool? selected;
  final Color activeColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool onColoredSurface;
  final IconData? icon;

  /// Ocupa todo el ancho que le den (por ejemplo, dentro de un `Expanded`).
  final bool expand;

  const AppPill({
    super.key,
    required this.label,
    this.selected,
    this.activeColor = AppColors.primaryPurple,
    this.onTap,
    this.onLongPress,
    this.onColoredSurface = false,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected == true;
    final Color background;
    final Color foreground;
    BoxBorder? border;
    if (isActive) {
      background = activeColor;
      foreground = AppColors.textPrimary;
    } else if (selected == false) {
      background = AppColors.glassSurface;
      foreground = AppColors.softText;
      border = Border.all(color: AppColors.cardBorder);
    } else if (onColoredSurface) {
      background = Colors.white.withValues(alpha: 0.15);
      foreground = AppColors.textPrimary;
    } else {
      background = AppColors.glassSurface;
      foreground = AppColors.softText;
    }

    Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: ShapeDecoration(
        color: background,
        shape: StadiumBorder(
          side: border == null
              ? BorderSide.none
              : const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
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
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: pill,
        ),
      ),
    );
  }
}
