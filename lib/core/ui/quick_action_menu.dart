import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../flow/general_flow_service.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import '../i18n/app_locale_controller.dart';
import 'app_colors.dart';
import 'widgets/app_sheet.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

class QuickActionMenu {
  static void open(BuildContext context, {String mode = "normal"}) {
    final bool isVault = mode == "vault";
    final l10n = context.read<AppLocaleController>();

    AppSheet.show<void>(
      context,
      horizontalPadding: 0,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSheetTitle(
              isVault
                  ? l10n.text('vault_register_title')
                  : l10n.text('quick_entry_question'),
            ),
            if (!isVault) ...[
              AppSheetOption(
                icon: AppIcons.quickEntry,
                label: l10n.text('quick_entry_title'),
                onTap: () {
                  GeneralFlowService.goBack();
                  GeneralFlowService.openEntry();
                },
              ),
              AppSheetOption(
                icon: AppIcons.add,
                color: AppColors.incomeGreen,
                label: l10n.text('add_income_label'),
                onTap: () {
                  GeneralFlowService.goBack();
                  ActionController.execute(context, AppAction.addIncome);
                },
              ),
              AppSheetOption(
                icon: AppIcons.remove,
                color: AppColors.expenseRed,
                label: l10n.text('add_expense_label'),
                onTap: () {
                  GeneralFlowService.goBack();
                  ActionController.execute(context, AppAction.addExpense);
                },
              ),
            ],
            AppSheetOption(
              icon: isVault ? AppIcons.add : AppIcons.vault,
              color: isVault ? AppColors.incomeGreen : AppColors.primaryPurple,
              label: isVault
                  ? l10n.text('add_private_income')
                  : l10n.text('add_private_movement'),
              onTap: () {
                GeneralFlowService.goBack();
                ActionController.openQuickEntryVault(
                  context,
                  type: isVault ? 'income' : null,
                );
              },
            ),
            if (isVault)
              AppSheetOption(
                icon: AppIcons.remove,
                color: AppColors.expenseRed,
                label: l10n.text('add_private_expense'),
                onTap: () {
                  GeneralFlowService.goBack();
                  ActionController.openQuickEntryVault(
                    context,
                    type: 'expense',
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
