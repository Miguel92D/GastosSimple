import 'package:flutter/material.dart';
import '../flow/transaction_flow_service.dart';
import './app_colors.dart';
import 'app_spacing.dart';
import 'widgets/app_round_button.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

/// Botones `+` (ingreso) y `−` (gasto) de abajo a la derecha.
class AppFAB extends StatelessWidget {
  final String mode;

  const AppFAB({super.key, this.mode = "normal"});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppRoundButton(
          icon: AppIcons.add,
          color: AppColors.incomeGreen,
          onTap: () => TransactionFlowService.instance.startQuickEntry(
            context,
            type: 'income',
            isVault: mode == "vault",
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppRoundButton(
          icon: AppIcons.remove,
          color: AppColors.expenseRed,
          onTap: () => TransactionFlowService.instance.startQuickEntry(
            context,
            type: 'expense',
            isVault: mode == "vault",
          ),
        ),
      ],
    );
  }
}
