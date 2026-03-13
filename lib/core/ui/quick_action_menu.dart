import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class QuickActionMenu {
  static void open(BuildContext context, {String mode = "normal"}) {
    final bool isVault = mode == "vault";

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      barrierColor: Colors.black.withValues(alpha: 0.75),
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
                      ? 'Registrar en Bóveda'
                      : '¿Qué quieres registrar hoy?',
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
                ),
              ),
              if (!isVault) ...[
                ListTile(
                  leading: const Icon(
                    Icons.flash_on_rounded,
                    color: AppColors.orange,
                  ),
                  title: Text('Entrada rápida', style: AppTextStyles.bodyMain),
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
                  title: Text('Agregar ingreso', style: AppTextStyles.bodyMain),
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
                  title: Text('Agregar gasto', style: AppTextStyles.bodyMain),
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
                      ? 'Agregar ingreso privado'
                      : 'Agregar movimiento privado',
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
                    'Agregar gasto privado',
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
