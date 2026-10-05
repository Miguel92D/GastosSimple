import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Botón secundario: violeta suave con borde, sin degradado. Alto 48,
/// radio `lg` (como `GradientButton`), texto en MAYÚSCULAS.
class AppSecondaryButton extends StatelessWidget {
  static const double height = 48;

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  /// Ocupa todo el ancho disponible.
  final bool expand;

  const AppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = AppColors.primaryPurple,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = enabled ? color : color.withValues(alpha: 0.4);
    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: Material(
        color: color.withValues(alpha: enabled ? 0.1 : 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: color.withValues(alpha: enabled ? 0.3 : 0.12),
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: fg, size: AppIconSize.normal),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    text.toUpperCase(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.secondaryButtonLabel.copyWith(
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
