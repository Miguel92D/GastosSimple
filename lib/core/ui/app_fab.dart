import 'package:flutter/material.dart';
import '../flow/transaction_flow_service.dart';
import './app_colors.dart';
import './glass_card.dart';

class AppFAB extends StatelessWidget {
  final String mode;

  const AppFAB({super.key, this.mode = "normal"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFab(
            context: context,
            icon: Icons.add_rounded,
            color: AppColors.incomeGreen,
            onPressed: () => TransactionFlowService.instance.startQuickEntry(
              context,
              type: 'income',
              isVault: mode == "vault",
            ),
            heroTag: "income_fab",
          ),
          const SizedBox(height: 16),
          _buildFab(
            context: context,
            icon: Icons.remove_rounded,
            color: AppColors.expenseRed,
            onPressed: () => TransactionFlowService.instance.startQuickEntry(
              context,
              type: 'expense',
              isVault: mode == "vault",
            ),
            heroTag: "expense_fab",
          ),
        ],
      ),
    );
  }

  Widget _buildFab({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return GlassCard(
      width: 56,
      height: 56,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      glowColor: color.withValues(alpha: 0.3),
      border: Border.all(color: color.withValues(alpha: 0.4), width: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(child: Icon(icon, color: color, size: 28)),
        ),
      ),
    );
  }
}
