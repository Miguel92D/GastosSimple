import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';


class IncomeExpenseCards extends StatelessWidget {
  final double income;
  final double expenses;
  final String? selectedFilter;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const IncomeExpenseCards({
    super.key,
    required this.income,
    required this.expenses,
    this.selectedFilter,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: context.watch<AppLocaleController>().text('income'),
                  amount: income,
                  color: AppColors.incomeGreen,
                  isSelected: selectedFilter == 'ingreso',
                  onTap: onIncomeTap,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: context.watch<AppLocaleController>().text('expense'),
                  amount: expenses,
                  color: AppColors.expenseRed,
                  isSelected: selectedFilter == 'gasto',
                  onTap: onExpenseTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GlassCard(
          glowColor: isSelected
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.08),
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppRadius.lg,
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.5), width: 2)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.subLabel.copyWith(
                  color: isSelected
                      ? color.withValues(alpha: 0.8)
                      : AppColors.softText.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                        color: color.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppState.instance.hideBalance
                          ? "••••••"
                          : NumberFormat('#,###', 'es_ES').format(amount.abs()),
                      style: AppTextStyles.incomeValue.copyWith(
                        color: color,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
