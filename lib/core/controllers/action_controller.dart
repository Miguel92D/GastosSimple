import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../flow/transaction_flow_service.dart';
import 'app_action.dart';

class ActionController {
  static void execute(
    BuildContext context,
    AppAction action, {
    Map<String, dynamic>? arguments,
  }) {
    switch (action) {
      case AppAction.openDashboard:
        GeneralFlowService.openDashboard();
        break;

      case AppAction.openVault:
        GeneralFlowService.openVault();
        break;

      case AppAction.addIncome:
        TransactionFlowService.instance.startQuickEntry(
          context,
          isVault: false,
          type: 'income',
        );
        break;

      case AppAction.addExpense:
        TransactionFlowService.instance.startQuickEntry(
          context,
          isVault: false,
          type: 'expense',
        );
        break;

      case AppAction.openEntry:
        GeneralFlowService.openEntry();
        break;

      case AppAction.openSettings:
        GeneralFlowService.openSettings();
        break;

      case AppAction.openStats:
        GeneralFlowService.openStats();
        break;

      case AppAction.openDebts:
        GeneralFlowService.openDebts();
        break;

      case AppAction.openGoals:
        GeneralFlowService.openGoals();
        break;

      case AppAction.openBudgets:
        GeneralFlowService.openBudgets();
        break;
    }
  }

  static void openQuickEntryNormal(BuildContext context) {
    execute(context, AppAction.openEntry);
  }

  static void openQuickEntryVault(BuildContext context) {
    TransactionFlowService.instance.startQuickEntry(context, isVault: true);
  }

  static void openDashboard(BuildContext context) {
    execute(context, AppAction.openDashboard);
  }

  static void openSettings(BuildContext context) {
    execute(context, AppAction.openSettings);
  }

  static void openVault(BuildContext context) {
    execute(context, AppAction.openVault);
  }
}
