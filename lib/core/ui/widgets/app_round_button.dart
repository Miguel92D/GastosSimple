import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_radius.dart';
import '../glass_card.dart';

/// Botón redondo de vidrio 56×56: `+` / `−` del inicio, `+` de Deudas y
/// Metas, y el botón de menú. Todos iguales (D-032).
class AppRoundButton extends StatelessWidget {
  static const double size = 56;

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? tooltip;

  const AppRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primaryPurple,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GlassCard(
      width: size,
      height: size,
      borderRadius: AppRadius.round,
      padding: EdgeInsets.zero,
      glowColor: color.withValues(alpha: 0.3),
      border: Border.all(color: color.withValues(alpha: 0.4), width: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.round),
          child: Center(
            child: Icon(icon, color: color, size: AppIconSize.button),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
