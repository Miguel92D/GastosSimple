import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';

/// Barra de progreso: alto 8, color liso, fondo blanco al 5%, animada.
/// Una sola en toda la app (Deudas, Metas, Estadísticas, "Podés gastar hoy").
class AppProgressBar extends StatelessWidget {
  static const double height = 8;

  /// De 0 a 1 (se recorta si se pasa).
  final double value;
  final Color color;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primaryPurple,
  });

  @override
  Widget build(BuildContext context) {
    final target = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.bar),
      child: Container(
        height: height,
        color: Colors.white.withValues(alpha: 0.05),
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: target),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.bar),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
