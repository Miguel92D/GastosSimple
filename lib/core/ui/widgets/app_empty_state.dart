import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import 'app_secondary_button.dart';

/// "No hay nada": ícono gris 64, texto, subtítulo y botón opcionales.
/// Mismo aspecto en todas las pantallas (D-032).
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.text,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.empty,
              color: AppColors.softText.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.softText.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppSecondaryButton(text: actionText!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
