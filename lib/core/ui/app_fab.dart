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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
