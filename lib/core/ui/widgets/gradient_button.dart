import 'package:flutter/material.dart';
import '../app_gradients.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;
  final double borderRadius;
  final IconData? icon;
  final bool animate;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors,
    this.borderRadius = 16,
    this.icon,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppGradients.primaryGradient.colors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.textPrimary, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(text, style: AppTextStyles.buttonLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
