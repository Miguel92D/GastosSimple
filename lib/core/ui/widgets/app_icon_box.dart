import 'package:flutter/material.dart';
import '../app_icons.dart';
import '../app_radius.dart';

/// Ícono dentro de una caja de color, al principio de una fila (movimiento,
/// deuda, pago fijo). 40×40, radio `sm`, ícono 20 (D-032).
class AppIconBox extends StatelessWidget {
  static const double size = 40;

  final IconData icon;
  final Color color;

  /// Color del fondo y del borde, si no es el del ícono (por ejemplo, gris
  /// para una deuda común con ícono blanco).
  final Color? boxColor;

  const AppIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.boxColor,
  });

  @override
  Widget build(BuildContext context) {
    final base = boxColor ?? color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: base.withValues(alpha: 0.15), width: 1),
      ),
      child: Icon(icon, color: color, size: AppIconSize.normal),
    );
  }
}
