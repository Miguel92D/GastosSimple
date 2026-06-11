import 'package:flutter/material.dart';
import 'glass_card.dart';
import 'app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Margen para el glow
      child: GlassCard(
        width: width ?? double.infinity,
        padding: EdgeInsets.zero,
        borderRadius: 24,
        glowColor: color.withValues(alpha: 0.3),
        shadowBlurRadius: 15,
        shadowOffset: const Offset(0, 8),
        shadowSpreadRadius: 0,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.0),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              alignment: Alignment.center,
              padding: padding ?? const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                label,
                style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
