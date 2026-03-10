/**
 * This project uses centralized layout constants.
 * Direct usage of hardcoded spacing values, radius values, or shadow definitions is discouraged.
 * Use AppSpacing, AppRadius, and AppShadows instead.
 */
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool isPro;

  const AppCard({super.key, required this.child, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: isPro
            ? [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [AppShadows.softShadow],
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
