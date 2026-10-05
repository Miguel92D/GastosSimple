import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/widgets/app_segmented.dart';
import '../controllers/dashboard_controller.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

/// Selector Día / Mes del inicio (usa `AppSegmented`).
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
        horizontal: AppSpacing.screen,
        vertical: AppSpacing.xs,
      ),
      child: AppSegmented<DashboardPeriod>(
        expand: true,
        selected: selectedPeriod,
        onChanged: onPeriodChanged,
        segments: [
          AppSegment(
            value: DashboardPeriod.day,
            label: l10n.text('period_day'),
            icon: AppIcons.day,
          ),
          AppSegment(
            value: DashboardPeriod.month,
            label: l10n.text('period_month'),
            icon: AppIcons.month,
          ),
        ],
      ),
    );
  }
}
