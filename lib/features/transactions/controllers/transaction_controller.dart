import '../../../core/flow/app_guard.dart';
import '../../../services/cloud_backup_service.dart';

import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../core/notifiers/transaction_notifier.dart';

class TransactionController {
  static Future<void> addTransaction(Transaction mov) async {
    await TransactionRepository.insertTransaction(mov);
    TransactionNotifier.instance.refresh();
    CloudBackupService.instance.tryAutoBackup();
  }

  static Future<void> addRecurringTransaction(
    Transaction mov,
    String frequency,
  ) async {
    await TransactionRepository.insertRecurringTransaction(mov, frequency);
    TransactionNotifier.instance.refresh();
    CloudBackupService.instance.tryAutoBackup();
  }

  static Future<void> updateTransaction(Transaction mov) async {
    await TransactionRepository.updateTransaction(mov);
    TransactionNotifier.instance.refresh();
    CloudBackupService.instance.tryAutoBackup();
  }

  static Future<void> deleteTransaction(int id) async {
    await TransactionRepository.deleteTransaction(id);
    TransactionNotifier.instance.refresh();
    CloudBackupService.instance.tryAutoBackup();
  }


  static Future<List<Transaction>> getNormalHistory() async {
    return await AppGuard.runSafe(
          () async => await TransactionRepository.getNormalTransactions(),
        ) ??
        [];
  }

  static Future<List<Transaction>> getVaultHistory() async {
    return await AppGuard.runSafe(
          () async => await TransactionRepository.getVaultTransactions(),
        ) ??
        [];
  }

  static Future<List<Transaction>> getIncome() async {
    return await AppGuard.runSafe(
          () async => await TransactionRepository.getIncomeTransactions(),
        ) ??
        [];
  }

  static Future<List<Transaction>> getExpense() async {
    return await AppGuard.runSafe(
          () async => await TransactionRepository.getExpenseTransactions(),
        ) ??
        [];
  }

  static Future<List<Transaction>> search(String query) async {
    return await AppGuard.runSafe(
          () async => await TransactionRepository.searchTransactions(query),
        ) ??
        [];
  }

  static Future<List<Transaction>> searchByType(
    String query,
    String type,
  ) async {
    return await AppGuard.runSafe(
          () async =>
              await TransactionRepository.searchTransactionsByType(query, type),
        ) ??
        [];
  }

  static Future<List<String>> getCategoriasOrdenadas(String type) async {
    return await TransactionRepository.getCategoriasOrdenadas(type);
  }

  static Future<double> getTotalIncome({bool isVault = false}) async {
    return await TransactionRepository.getTotalIncome(isVault: isVault);
  }

  static Future<double> getTotalExpenses({bool isVault = false}) async {
    return await TransactionRepository.getTotalExpenses(isVault: isVault);
  }

  static Future<Map<String, double>> getExpensesByCategory({
    bool isVault = false,
  }) async {
    return await TransactionRepository.getExpensesByCategory(isVault: isVault);
  }

  static Future<List<Transaction>> getTransactionsInMonth({
    DateTime? month,
    bool isVault = false,
  }) async {
    return await TransactionRepository.getTransactionsInMonth(
      month: month,
      isVault: isVault,
    );
  }

  static Future<void> processRecurringTransactions() async {
    await TransactionRepository.processRecurringTransactions();
    TransactionNotifier.instance.refresh();
  }
}
