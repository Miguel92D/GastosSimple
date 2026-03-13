import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../flow/transaction_flow_service.dart';
import '../flow/premium_flow_service.dart';
import '../state/app_state.dart';
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
        if (AppState.instance.isPro) {
          GeneralFlowService.openVault();
        } else {
          PremiumFlowService.showUpgradePrompt(context);
        }
        break;

      case AppAction.addIncome:
        TransactionFlowService.instance.startQuickEntry(
          context,
          isVault: false,
          type: 'income',
          arguments: arguments,
        );
        break;

      case AppAction.addExpense:
        TransactionFlowService.instance.startQuickEntry(
          context,
          isVault: false,
          type: 'expense',
          arguments: arguments,
        );
        break;

      case AppAction.openEntry:
        GeneralFlowService.openEntry();
        break;

      case AppAction.openSettings:
        GeneralFlowService.openSettings();
        break;

      case AppAction.openStats:
        if (AppState.instance.isPro) {
          GeneralFlowService.openStats();
        } else {
          PremiumFlowService.showUpgradePrompt(context);
        }
        break;

      case AppAction.openDebts:
        GeneralFlowService.openDebts();
        break;

      case AppAction.openGoals:
        if (AppState.instance.isPro) {
          GeneralFlowService.openGoals();
        } else {
          PremiumFlowService.showUpgradePrompt(context);
        }
        break;


      case AppAction.openPrediction:
        if (AppState.instance.isPro) {
          GeneralFlowService.openPrediction();
        } else {
          PremiumFlowService.showUpgradePrompt(context);
        }
        break;

      case AppAction.openBudgets:
        if (AppState.instance.isPro) {
          GeneralFlowService.openBudgets();
        } else {
          PremiumFlowService.showUpgradePrompt(context);
        }
        break;
      case AppAction.openCategories:
        GeneralFlowService.openCategories();
        break;
      case AppAction.openMonthlyAnalysis:
        if (AppState.instance.isPro) {
          GeneralFlowService.openMonthlyAnalysis();
        } else {
          PremiumFlowService.showUpgradePrompt(context);
        }
        break;
    }

  }

  static void openQuickEntryNormal(BuildContext context) {
    execute(context, AppAction.openEntry);
  }

  static void openQuickEntryVault(BuildContext context) {
    if (AppState.instance.isPro) {
      TransactionFlowService.instance.startQuickEntry(context, isVault: true);
    } else {
      PremiumFlowService.showUpgradePrompt(context);
    }
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
