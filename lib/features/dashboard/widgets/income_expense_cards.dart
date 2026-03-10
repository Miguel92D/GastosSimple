import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';

class IncomeExpenseCards extends StatelessWidget {
  final double income;
  final double expenses;

  const IncomeExpenseCards({
    super.key,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "Ingresos",
              amount: income,
              color: AppColors.incomeGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              label: "Gastos",
              amount: expenses,
              color: AppColors.expenseRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: color.withOpacity(0.08),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.subLabel.copyWith(
              color: AppColors.softText.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "\$",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  NumberFormat('#,###', 'es_ES').format(amount.abs()),
                  style: AppTextStyles.incomeValue.copyWith(
                    color: color,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
