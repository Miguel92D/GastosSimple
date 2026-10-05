import 'package:flutter/material.dart';
import '../app_icons.dart';
import '../app_radius.dart';

/// Botón chico 38×38 de una acción (pagar, editar, borrar) dentro de una
/// tarjeta. Mismo aspecto en Deudas y Metas (D-032).
class AppActionButton extends StatelessWidget {
  static const double size = 38;

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AppActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Center(
          child: Icon(icon, size: AppIconSize.normal, color: color),
        ),
      ),
    );
  }
}
