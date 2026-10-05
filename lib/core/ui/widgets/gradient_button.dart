import 'package:flutter/material.dart';
import '../app_gradients.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final double borderRadius;
  final IconData? icon;
  final bool animate;

  /// Color del texto y del ícono. Sobre dorado va `darkBackground`.
  final Color foregroundColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors,
    this.borderRadius = AppRadius.lg,
    this.icon,
    this.animate = false,
    this.foregroundColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppGradients.primaryGradient.colors;
    final isEnabled = onPressed != null;
    final disabledBase = AppColors.softText.withValues(alpha: 0.22);
    final effectiveColors = isEnabled ? colors : [disabledBase, disabledBase];

    return Padding(
      // Protección para la sombra
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: effectiveColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: effectiveColors.first.withValues(
                alpha: isEnabled ? 0.3 : 0.12,
              ),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isEnabled
                          ? foregroundColor
                          : foregroundColor.withValues(alpha: 0.55),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  // Botón principal siempre en MAYÚSCULAS (D-029).
                  Flexible(
                    child: Text(
                      text.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonLabel.copyWith(
                        color: isEnabled
                            ? foregroundColor
                            : foregroundColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
