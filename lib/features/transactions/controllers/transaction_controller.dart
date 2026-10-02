import '../../../core/flow/app_guard.dart';

import '../models/transaction.dart';
import '../models/recurring_payment.dart';
import '../../../core/utils/installment_plan.dart';
import '../../../database/database_helper.dart';
import '../repositories/transaction_repository.dart';
import '../../../core/notifiers/transaction_notifier.dart';

class TransactionController {
  static Future<void> addTransaction(Transaction mov) async {
    await TransactionRepository.insertTransaction(mov);
    TransactionNotifier.instance.refresh();
  }

  static Future<void> addRecurringTransaction(
    Transaction mov,
    String frequency,
  ) async {
    await TransactionRepository.insertRecurringTransaction(mov, frequency);
    // Si el movimiento tiene fecha pasada, se generan ya las ocurrencias
    // que vencieron desde entonces.
    await TransactionRepository.processRecurringTransactions();
    TransactionNotifier.instance.refresh();
  }

  /// Compra en cuotas. [purchase.amount] es el TOTAL a pagar (con recargo
  /// si lo hay). La primera cuota vence en [firstDate]: la fecha de compra o
  /// el vencimiento de la tarjeta. Las cuotas ya vencidas se registran ahora;
  /// las futuras, cuando llegue su fecha.
  static Future<void> addInstallmentPurchase(
    Transaction purchase, {
    required int installments,
    required DateTime firstDate,
    int? anchorDay,
  }) async {
    await DatabaseHelper.instance.insertInstallmentPlan(
      anchorDay: anchorDay,
      perInstallment: InstallmentPlan.perInstallment(
        purchase.amount,
        installments,
      ),
      totalAmount: purchase.amount,
      count: installments,
      firstDate: firstDate,
      category: purchase.category,
      type: purchase.type,
      isSecret: purchase.isSecret,
      baseNote: purchase.note,
    );
    await TransactionRepository.processRecurringTransactions();
    TransactionNotifier.instance.refresh();
  }

  static Future<List<RecurringPayment>> getRecurringPayments({
    bool isVault = false,
  }) async {
    final rows = await DatabaseHelper.instance.getRecurringTransactions(
      isSecret: isVault,
    );
    return rows.map(RecurringPayment.fromMap).toList();
  }

  static Future<void> updateRecurringAmount(int id, double amount) async {
    await DatabaseHelper.instance.updateRecurringAmount(id, amount);
    TransactionNotifier.instance.refresh();
  }

  static Future<void> cancelRecurring(int id) async {
    await DatabaseHelper.instance.deleteRecurringTransaction(id);
    TransactionNotifier.instance.refresh();
  }

  static Future<void> updateTransaction(Transaction mov) async {
    await TransactionRepository.updateTransaction(mov);
    TransactionNotifier.instance.refresh();
  }

  /// Deshacer un borrado: reinserta el movimiento con su id original.
  static Future<void> restoreDeleted(Transaction mov) async {
    await DatabaseHelper.instance.restoreTransaction(mov);
    TransactionNotifier.instance.refresh();
  }

  static Future<void> deleteTransaction(int id) async {
    await TransactionRepository.deleteTransaction(id);
    TransactionNotifier.instance.refresh();
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

  static Future<List<Transaction>> getTransactionsForDay(
    DateTime day, {
    bool isVault = false,
  }) async {
    return await TransactionRepository.getTransactionsForDay(
      day,
      isVault: isVault,
    );
  }

  static Future<void> processRecurringTransactions() async {
    await TransactionRepository.processRecurringTransactions();
    TransactionNotifier.instance.refresh();
  }
}
