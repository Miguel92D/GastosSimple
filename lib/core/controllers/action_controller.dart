import 'package:flutter/material.dart';
import '../router/navigation_service.dart';
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
        NavigationService.navigateAndRemoveUntil("/dashboard");
        break;

      case AppAction.openVault:
        NavigationService.navigate("/vault");
        break;

      case AppAction.addIncome:
        TransactionFlowService.instance.startQuickEntry(
          context,
          isVault: false,
        );
        break;

      case AppAction.addExpense:
        TransactionFlowService.instance.startQuickEntry(
          context,
          isVault: false,
        );
        break;

      case AppAction.openEntry:
        NavigationService.navigateAndRemoveUntil("/");
        break;

      case AppAction.openSettings:
        NavigationService.navigate("/settings");
        break;

      case AppAction.openStats:
        NavigationService.navigate("/stats");
        break;

      case AppAction.openDebts:
        NavigationService.navigate("/debts");
        break;

      case AppAction.openGoals:
        NavigationService.navigate("/goals");
        break;

      case AppAction.openBudgets:
        NavigationService.navigate("/budgets");
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
