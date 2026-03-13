/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_shadows.dart';
import '../../../core/state/app_mode_controller.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;

  const DashboardCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isPro = AppModeController.instance.isPro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: isPro
            ? AppGradients.primaryGradient
            : AppGradients.glassGradient,
        border: isPro ? null : Border.all(color: AppColors.cardBorder),
        boxShadow: [
          if (isPro)
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          else
            AppShadows.softShadow,
        ],
      ),
      child: child,
    );
  }
}
