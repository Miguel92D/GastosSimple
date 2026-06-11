import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/services/monthly_finance_service.dart';

void main() {
  Transaction tx({
    required double amount,
    required String type,
    required DateTime date,
    String category = 'Otros',
  }) {
    return Transaction(
      amount: amount,
      category: category,
      type: type,
      date: date,
    );
  }

  test('filters movements by selected month without losing history', () {
    final movements = [
      tx(amount: 500, type: 'ingreso', date: DateTime(2026, 4, 30)),
      tx(amount: 1000, type: 'ingreso', date: DateTime(2026, 5, 1)),
      tx(amount: 250, type: 'gasto', date: DateTime(2026, 5, 12)),
      tx(amount: 300, type: 'gasto', date: DateTime(2026, 6, 1)),
    ];

    final may = MonthlyFinanceService.filterTransactionsForMonth(
      movements,
      DateTime(2026, 5),
    );
    final april = MonthlyFinanceService.filterTransactionsForMonth(
      movements,
      DateTime(2026, 4),
    );

    expect(movements, hasLength(4));
    expect(may, hasLength(2));
    expect(april, hasLength(1));
    expect(MonthlyFinanceService.calculateIncome(may), 1000);
    expect(MonthlyFinanceService.calculateExpenses(may), 250);
    expect(MonthlyFinanceService.calculateBalance(may), 750);
  });

  test('empty month returns zero income, expenses, and balance', () {
    final emptyMonth = <Transaction>[];

    expect(MonthlyFinanceService.calculateIncome(emptyMonth), 0);
    expect(MonthlyFinanceService.calculateExpenses(emptyMonth), 0);
    expect(MonthlyFinanceService.calculateBalance(emptyMonth), 0);
  });

  test('monthly analysis matches dashboard totals for the same month', () {
    final mayMovements = [
      tx(amount: 1200, type: 'ingreso', date: DateTime(2026, 5, 3)),
      tx(amount: 200, type: 'gasto', date: DateTime(2026, 5, 4)),
      tx(amount: 400, type: 'gasto', date: DateTime(2026, 5, 4)),
    ];
    final aprilMovements = [
      tx(amount: 300, type: 'gasto', date: DateTime(2026, 4, 20)),
    ];

    final analysis = MonthlyFinanceService.buildAnalysis(
      currentMonthTransactions: mayMovements,
      previousMonthTransactions: aprilMovements,
      selectedMonth: DateTime(2026, 5),
      now: DateTime(2026, 5, 21),
    );

    expect(
      analysis.income,
      MonthlyFinanceService.calculateIncome(mayMovements),
    );
    expect(
      analysis.expenses,
      MonthlyFinanceService.calculateExpenses(mayMovements),
    );
    expect(
      analysis.balance,
      MonthlyFinanceService.calculateBalance(mayMovements),
    );
    expect(analysis.previousMonthExpenses, 300);
    expect(analysis.topSpendingDay, '4');
    expect(analysis.dailyAverage, closeTo(600 / 21, 0.001));
  });

  test('previous complete months use days in that month for daily average', () {
    final februaryMovements = [
      tx(amount: 280, type: 'gasto', date: DateTime(2026, 2, 10)),
    ];

    final analysis = MonthlyFinanceService.buildAnalysis(
      currentMonthTransactions: februaryMovements,
      previousMonthTransactions: const [],
      selectedMonth: DateTime(2026, 2),
      now: DateTime(2026, 5, 21),
    );

    expect(analysis.dailyAverage, 10);
  });
}
