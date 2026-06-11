import '../../transactions/controllers/transaction_controller.dart';
import '../../transactions/models/transaction.dart';
import '../../../services/monthly_finance_service.dart';

class DashboardController {
  Future<List<Transaction>> loadMovements(
    bool isVault, {
    DateTime? month,
  }) async {
    if (month != null) {
      return await TransactionController.getTransactionsInMonth(
        month: month,
        isVault: isVault,
      );
    }

    return isVault
        ? await TransactionController.getVaultHistory()
        : await TransactionController.getNormalHistory();
  }

  double calculateIncome(List<Transaction> movimientos) {
    return MonthlyFinanceService.calculateIncome(movimientos);
  }

  double calculateExpenses(List<Transaction> movimientos) {
    return MonthlyFinanceService.calculateExpenses(movimientos);
  }

  double calculateBalance(List<Transaction> movimientos) {
    return MonthlyFinanceService.calculateBalance(movimientos);
  }

  Future<double> getIncome(bool isVault) async {
    return await TransactionController.getTotalIncome(isVault: isVault);
  }

  Future<double> getExpenses(bool isVault) async {
    return await TransactionController.getTotalExpenses(isVault: isVault);
  }

  Future<double> getBalance(bool isVault) async {
    final income = await getIncome(isVault);
    final expenses = await getExpenses(isVault);
    return income - expenses;
  }

  Future<Map<String, double>> getExpensesByCategory(bool isVault) async {
    return await TransactionController.getExpensesByCategory(isVault: isVault);
  }
}
