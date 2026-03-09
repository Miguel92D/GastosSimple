import '../../transactions/controllers/transaction_controller.dart';
import '../../transactions/models/transaction.dart';

class DashboardController {
  Future<List<Transaction>> loadMovements(bool isVault) async {
    return isVault
        ? await TransactionController.getVaultHistory()
        : await TransactionController.getNormalHistory();
  }

  double calculateIncome(List<Transaction> movimientos) {
    return movimientos
        .where((m) => m.type == "ingreso")
        .fold(0.0, (sum, m) => sum + m.amount);
  }

  double calculateExpenses(List<Transaction> movimientos) {
    return movimientos
        .where((m) => m.type == "gasto")
        .fold(0.0, (sum, m) => sum + m.amount);
  }

  double calculateBalance(List<Transaction> movimientos) {
    return calculateIncome(movimientos) - calculateExpenses(movimientos);
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
