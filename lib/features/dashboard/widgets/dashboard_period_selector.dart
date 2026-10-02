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
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withValues(alpha: 0.28)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm + 4),
          border: isSelected
              ? Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.55),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.softText.withValues(alpha: 0.5),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.subLabel.copyWith(
                fontSize: 11,
                letterSpacing: 1.2,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.softText.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
