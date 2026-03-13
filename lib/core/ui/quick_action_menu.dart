import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../flow/general_flow_service.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import '../i18n/app_locale_controller.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class QuickActionMenu {
  static void open(BuildContext context, {String mode = "normal"}) {
    final bool isVault = mode == "vault";
    final l10n = context.read<AppLocaleController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      barrierColor: Colors.black.withOpacity(0.75),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  isVault
                      ? l10n.text('vault_register_title')
                      : l10n.text('quick_entry_question'),
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
                ),
              ),
              if (!isVault) ...[
                ListTile(
                  leading: const Icon(
                    Icons.flash_on_rounded,
                    color: AppColors.orange,
                  ),
                  title: Text(l10n.text('quick_entry_title'), style: AppTextStyles.bodyMain),
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openEntry();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.incomeGreen,
                  ),
                  title: Text(l10n.text('add_income_label'), style: AppTextStyles.bodyMain),
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.addIncome);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.expenseRed,
                  ),
                  title: Text(l10n.text('add_expense_label'), style: AppTextStyles.bodyMain),
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.addExpense);
                  },
                ),
              ],
              ListTile(
                leading: Icon(
                  isVault ? Icons.arrow_upward_rounded : Icons.lock_rounded,
                  color: isVault ? AppColors.incomeGreen : AppColors.orange,
                ),
                title: Text(
                  isVault
                      ? l10n.text('add_private_income')
                      : l10n.text('add_private_movement'),
                  style: AppTextStyles.bodyMain,
                ),
                onTap: () {
                  GeneralFlowService.goBack();
                  ActionController.openQuickEntryVault(context);
                },
              ),
              if (isVault)
                ListTile(
                  leading: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.expenseRed,
                  ),
                  title: Text(
                    l10n.text('add_private_expense'),
                    style: AppTextStyles.bodyMain,
                  ),
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.openQuickEntryVault(context);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
