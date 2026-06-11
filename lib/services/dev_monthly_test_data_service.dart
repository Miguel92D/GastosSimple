import 'package:flutter/foundation.dart';

import '../features/transactions/controllers/transaction_controller.dart';
import '../features/transactions/models/transaction.dart';

class DevMonthlyTestDataResult {
  final int inserted;
  final int deleted;
  final List<Transaction> transactions;

  const DevMonthlyTestDataResult({
    required this.inserted,
    required this.deleted,
    required this.transactions,
  });
}

class DevMonthlyTestDataService {
  static const String testPrefix = 'TEST_MENSUAL_';

  static Future<DevMonthlyTestDataResult> loadMonthlyTestData({
    DateTime? now,
  }) async {
    _ensureDebugMode();

    final deleted = await deleteMonthlyTestData();
    final transactions = buildMonthlyTestTransactions(now: now);

    for (final transaction in transactions) {
      await TransactionController.addTransaction(transaction);
    }

    return DevMonthlyTestDataResult(
      inserted: transactions.length,
      deleted: deleted,
      transactions: transactions,
    );
  }

  static Future<int> deleteMonthlyTestData() async {
    _ensureDebugMode();

    final transactions = await TransactionController.getNormalHistory();
    final testTransactions = transactions.where(_isMonthlyTestTransaction);

    var deleted = 0;
    for (final transaction in testTransactions) {
      final id = transaction.id;
      if (id == null) continue;

      await TransactionController.deleteTransaction(id);
      deleted++;
    }

    return deleted;
  }

  static List<Transaction> buildMonthlyTestTransactions({DateTime? now}) {
    final currentMonth = _normalizeMonth(now ?? DateTime.now());
    final previousMonth = DateTime(
      currentMonth.year,
      currentMonth.month - 1,
    );
    final twoMonthsAgo = DateTime(
      currentMonth.year,
      currentMonth.month - 2,
    );

    return [
      _transaction(
        amount: 6000,
        category: 'Salario',
        type: Transaction.typeIncome,
        month: currentMonth,
        day: 5,
        note: '${testPrefix}Salario actual',
      ),
      _transaction(
        amount: 568,
        category: 'Comida',
        type: Transaction.typeExpense,
        month: currentMonth,
        day: 21,
        note: '${testPrefix}Comida actual',
      ),
      _transaction(
        amount: 350,
        category: 'Transporte',
        type: Transaction.typeExpense,
        month: currentMonth,
        day: 12,
        note: '${testPrefix}Transporte actual',
      ),
      _transaction(
        amount: 5000,
        category: 'Salario',
        type: Transaction.typeIncome,
        month: previousMonth,
        day: 4,
        note: '${testPrefix}Salario mes anterior',
      ),
      _transaction(
        amount: 1800,
        category: 'Alquiler',
        type: Transaction.typeExpense,
        month: previousMonth,
        day: 10,
        note: '${testPrefix}Alquiler mes anterior',
      ),
      _transaction(
        amount: 950,
        category: 'Comida',
        type: Transaction.typeExpense,
        month: previousMonth,
        day: 17,
        note: '${testPrefix}Comida mes anterior',
      ),
      _transaction(
        amount: 720,
        category: 'Servicios',
        type: Transaction.typeExpense,
        month: previousMonth,
        day: 22,
        note: '${testPrefix}Servicios mes anterior',
      ),
      _transaction(
        amount: 4500,
        category: 'Salario',
        type: Transaction.typeIncome,
        month: twoMonthsAgo,
        day: 3,
        note: '${testPrefix}Salario dos meses atras',
      ),
      _transaction(
        amount: 700,
        category: 'Comida',
        type: Transaction.typeExpense,
        month: twoMonthsAgo,
        day: 8,
        note: '${testPrefix}Comida dos meses atras',
      ),
      _transaction(
        amount: 400,
        category: 'Transporte',
        type: Transaction.typeExpense,
        month: twoMonthsAgo,
        day: 18,
        note: '${testPrefix}Transporte dos meses atras',
      ),
    ];
  }

  static bool _isMonthlyTestTransaction(Transaction transaction) {
    return transaction.isSecret == 0 &&
        (transaction.note?.startsWith(testPrefix) ?? false);
  }

  static Transaction _transaction({
    required double amount,
    required String category,
    required String type,
    required DateTime month,
    required int day,
    required String note,
  }) {
    return Transaction(
      amount: amount,
      category: category,
      type: type,
      date: DateTime(month.year, month.month, day, 12),
      isSecret: 0,
      note: note,
    );
  }

  static DateTime _normalizeMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static void _ensureDebugMode() {
    if (!kDebugMode) {
      throw StateError('Monthly test data is only available in debug mode.');
    }
  }
}
