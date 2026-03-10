import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/glass_card.dart';
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
              icon: Icons.arrow_upward_rounded,
              color: AppColors.income,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              label: "Gastos",
              amount: expenses,
              icon: Icons.arrow_downward_rounded,
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
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "\$",
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  NumberFormat('#,###', 'es_ES').format(amount.abs()),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
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
