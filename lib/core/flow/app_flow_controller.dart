import '../router/navigation_service.dart';
import '../router/app_routes.dart';

class AppFlowController {
  static void startApp() {
    NavigationService.navigate(AppRoutes.entryMenu);
  }

  static void openDashboard() {
    NavigationService.navigate(AppRoutes.home);
  }

  static void addIncome() {
    NavigationService.navigate(AppRoutes.addTransaction);
  }

  static void addExpense() {
    NavigationService.navigate(AppRoutes.addTransaction);
  }

  static void openVault() {
    NavigationService.navigate(AppRoutes.vault);
  }
}
