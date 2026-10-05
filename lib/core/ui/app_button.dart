import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'widgets/gradient_button.dart';

/// Botón principal de un color. Por dentro es un [GradientButton] (mismo
/// alto, radio, sombra y MAYÚSCULAS, D-029):
/// - violeta → el gradiente de marca;
/// - dorado (Pro) → dorado liso con texto oscuro (blanco sobre dorado no se lee);
/// - otro color → ese color liso.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isBrand = color == AppColors.primaryPurple;
    final isGold = color == AppColors.gold;
    return SizedBox(
      width: width ?? double.infinity,
      child: GradientButton(
        text: label,
        onPressed: onTap,
        gradientColors: isBrand ? null : [color, color],
        foregroundColor: isGold
            ? AppColors.darkBackground
            : AppColors.textPrimary,
      ),
    );
  }
}
