import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/design/app_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "Ingresos",
              amount: income,
              color: AppColors.income,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              label: "Gastos",
              amount: expenses,
              color: AppColors.expense,
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
      glowColor: color.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "\$",
                  style: TextStyle(
                    color: color.withOpacity(0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  NumberFormat('#,###', 'es_ES').format(amount.abs()),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: -0.5,
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
