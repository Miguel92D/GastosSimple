import 'package:flutter/material.dart';
import '../router/navigation_service.dart';
import '../../services/security_service.dart';
import '../../features/settings/screens/pin_screen.dart';
import 'transaction_flow_service.dart';

class GeneralFlowService {
  static void openDashboard() {
    SecurityService.instance.lockVault();
    NavigationService.navigateAndRemoveUntil("/dashboard");
  }

  static void openVault() {
    final security = SecurityService.instance;
    security.lockVault(); // Always lock when attempting to open to ensure PIN is requested
    if (security.isVaultPinActive) {
      NavigationService.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const PinScreen(isVault: true),
        ),
      ).then((value) {
        if (value == true) {
          NavigationService.navigateAndRemoveUntil("/vault");
        }
      });
    } else {
      NavigationService.navigateAndRemoveUntil("/vault");
    }
  }

  static void openSettings() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/settings");
  }

  static void openStats() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/stats");
  }

  static void openDebts() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/debts");
  }

  static void openGoals() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/goals");
  }

  static void openBudgets() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/budgets");
  }

  static void openEntry() {
    SecurityService.instance.lockVault();
    NavigationService.navigateAndRemoveUntil("/quick_entry");
  }

  static void openMovements() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/movements");
  }

  static void openPrediction() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/prediction");
  }

  static void openQuickEntryVault({String? type}) {
    final security = SecurityService.instance;
    security.lockVault(); // Always lock
    if (security.isVaultPinActive) {
      NavigationService.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const PinScreen(isVault: true),
        ),
      ).then((value) {
        if (value == true) {
          TransactionFlowService.instance.startQuickEntry(
            NavigationService.navigatorKey.currentContext!,
            isVault: true,
            type: type,
          );
        }
      });
    } else {
      TransactionFlowService.instance.startQuickEntry(
        NavigationService.navigatorKey.currentContext!,
        isVault: true,
        type: type,
      );
    }
  }

  static void openPrivacy() {
    NavigationService.navigate("/privacy");
  }

  static void openCategories() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/categories");
  }

  static void openMonthlyAnalysis() {
    SecurityService.instance.lockVault();
    NavigationService.navigate("/monthly_analysis");
  }


  static void goBack() {
    NavigationService.goBack();
  }
}
