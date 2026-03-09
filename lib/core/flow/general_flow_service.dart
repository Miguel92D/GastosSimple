import '../router/navigation_service.dart';

class GeneralFlowService {
  static void openDashboard() {
    NavigationService.navigateAndRemoveUntil("/dashboard");
  }

  static void openVault() {
    NavigationService.navigate("/vault");
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

  static void goBack() {
    NavigationService.goBack();
  }
}
