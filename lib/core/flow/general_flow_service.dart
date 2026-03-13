import 'package:flutter/material.dart';
import '../router/navigation_service.dart';
import '../../services/security_service.dart';
import '../../features/settings/screens/pin_screen.dart';

class GeneralFlowService {
  static void openDashboard() {
    NavigationService.navigateAndRemoveUntil("/dashboard");
  }

  static void openVault() {
    final security = SecurityService.instance;
    if (security.isVaultPinActive && !security.isVaultUnlocked) {
      NavigationService.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const PinScreen(isVault: true),
        ),
      ).then((value) {
        if (value == true) {
          NavigationService.navigate("/vault");
        }
      });
    } else {
      NavigationService.navigate("/vault");
    }
  }

  static void openSettings() {
    NavigationService.navigate("/settings");
  }

  static void openStats() {
    NavigationService.navigate("/stats");
  }

  static void openDebts() {
    NavigationService.navigate("/debts");
  }

  static void openGoals() {
    NavigationService.navigate("/goals");
  }

  static void openBudgets() {
    NavigationService.navigate("/budgets");
  }

  static void openEntry() {
    NavigationService.navigateAndRemoveUntil("/quick_entry");
  }

  static void openMovements() {
    NavigationService.navigate("/movements");
  }

  static void openPrediction() {
    NavigationService.navigate("/prediction");
  }

  static void openPrivacy() {
    NavigationService.navigate("/privacy");
  }

  static void openCategories() {
    NavigationService.navigate("/categories");
  }

  static void openMonthlyAnalysis() {
    NavigationService.navigate("/monthly_analysis");
  }


  static void goBack() {
    NavigationService.goBack();
  }
}
