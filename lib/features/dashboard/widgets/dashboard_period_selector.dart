import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPeriodSelector extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  const DashboardPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: GlassCard(
        borderRadius: AppRadius.md,
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: _PeriodTab(
                label: l10n.text('period_day'),
                icon: Icons.calendar_today_rounded,
                isSelected: selectedPeriod == DashboardPeriod.day,
                onTap: () => onPeriodChanged(DashboardPeriod.day),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _PeriodTab(
                label: l10n.text('period_month'),
                icon: Icons.calendar_month_rounded,
                isSelected: selectedPeriod == DashboardPeriod.month,
                onTap: () => onPeriodChanged(DashboardPeriod.month),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        // Opción de segmentado (skill diseno-simple): 20×10, radio sm,
        // fondo de color cuando está activa.
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.softText.withValues(alpha: 0.6),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Mismo peso en los dos estados: la palabra no se "mueve".
            Text(
              label.toUpperCase(),
              style: AppTextStyles.subLabel.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.softText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
