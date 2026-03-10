import 'package:flutter/material.dart';
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
      glowColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "\$${amount.toStringAsFixed(0)}",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
