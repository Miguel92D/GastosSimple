import 'package:flutter/material.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import './design/app_colors.dart';

class AppFAB extends StatelessWidget {
  final String mode;

  const AppFAB({super.key, this.mode = "normal"});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFab(
          context: context,
          icon: Icons.add_rounded,
          color: AppColors.income,
          onPressed: () =>
              ActionController.execute(context, AppAction.addIncome),
          heroTag: "income_fab",
        ),
        const SizedBox(height: 16),
        _buildFab(
          context: context,
          icon: Icons.remove_rounded,
          color: AppColors.expense,
          onPressed: () =>
              ActionController.execute(context, AppAction.addExpense),
          heroTag: "expense_fab",
        ),
        const SizedBox(height: 80), // Space for bottom navigation
      ],
    );
  }

  Widget _buildFab({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: color,
        elevation: 0,
        shape: const CircleBorder(),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
