import '../../../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static Future<void> insertTransaction(Transaction mov) async {
    await DatabaseHelper.instance.insertTransaction(mov);
  }

  static Future<void> insertRecurringTransaction(
    Transaction mov,
    String frequency,
  ) async {
    await DatabaseHelper.instance.insertRecurringTransaction(mov, frequency);
  }

  static Future<List<Transaction>> getNormalTransactions() async {
    return await DatabaseHelper.instance.getAllTransactions();
  }

  static Future<List<Transaction>> getVaultTransactions() async {
    return await DatabaseHelper.instance.getSecretTransactions();
  }

  static Future<void> updateTransaction(Transaction mov) async {
    await DatabaseHelper.instance.updateTransaction(mov);
  }

  static Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
  }

  static Future<List<Transaction>> getIncomeTransactions() async {
    return await DatabaseHelper.instance.getTransactionsByType('ingreso');
  }

  static Future<List<Transaction>> getExpenseTransactions() async {
    return await DatabaseHelper.instance.getTransactionsByType('gasto');
  }

  static Future<List<Transaction>> searchTransactions(String query) async {
    return await DatabaseHelper.instance.searchTransactions(query);
  }

  static Future<List<Transaction>> searchTransactionsByType(
    String query,
    String type,
  ) async {
    return await DatabaseHelper.instance.searchTransactionsByType(query, type);
  }

  static Future<List<String>> getCategoriasOrdenadas(String type) async {
    return await DatabaseHelper.instance.getCategoriasOrdenadas(type);
  }

  static Future<double> getTotalIncome({bool isVault = false}) async {
    return await DatabaseHelper.instance.getTotalIncome(isVault: isVault);
  }

  static Future<double> getTotalExpenses({bool isVault = false}) async {
    return await DatabaseHelper.instance.getTotalExpenses(isVault: isVault);
  }

  static Future<Map<String, double>> getExpensesByCategory({
    bool isVault = false,
  }) async {
    return await DatabaseHelper.instance.getExpensesByCategory(
      isVault: isVault,
    );
  }

  static Future<List<Transaction>> getTransactionsInMonth({
    DateTime? month,
    bool isVault = false,
  }) async {
    return await DatabaseHelper.instance.getTransactionsInMonth(
      month: month,
      isSecret: isVault,
    );
  }

  static Future<void> processRecurringTransactions() async {
    await DatabaseHelper.instance.processRecurringTransactions();
  }

  static Future<List<Transaction>> getTransactionsToday({
    bool isVault = false,
  }) async {
    return await DatabaseHelper.instance.getTransactionsToday(
      isSecret: isVault,
    );
  }
}
