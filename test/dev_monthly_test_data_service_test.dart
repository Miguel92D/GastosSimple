import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/services/dev_monthly_test_data_service.dart';
import 'package:gastos_simple/services/monthly_finance_service.dart';

void main() {
  test('builds monthly test data across current and previous months', () {
    final transactions = DevMonthlyTestDataService.buildMonthlyTestTransactions(
      now: DateTime(2026, 5, 21),
    );

    final currentMonth = MonthlyFinanceService.filterTransactionsForMonth(
      transactions,
      DateTime(2026, 5),
    );
    final previousMonth = MonthlyFinanceService.filterTransactionsForMonth(
      transactions,
      DateTime(2026, 4),
    );
    final twoMonthsAgo = MonthlyFinanceService.filterTransactionsForMonth(
      transactions,
      DateTime(2026, 3),
    );

    expect(transactions, hasLength(10));
    expect(currentMonth, hasLength(3));
    expect(previousMonth, hasLength(4));
    expect(twoMonthsAgo, hasLength(3));
  });

  test('monthly test data uses identifiable notes and non-secret movements', () {
    final transactions = DevMonthlyTestDataService.buildMonthlyTestTransactions(
      now: DateTime(2026, 5, 21),
    );

    expect(
      transactions.every(
        (transaction) =>
            transaction.isSecret == 0 &&
            transaction.note != null &&
            transaction.note!.startsWith(
              DevMonthlyTestDataService.testPrefix,
            ),
      ),
      isTrue,
    );
  });

  test('monthly test data has expected balances per month', () {
    final transactions = DevMonthlyTestDataService.buildMonthlyTestTransactions(
      now: DateTime(2026, 5, 21),
    );

    final currentMonth = MonthlyFinanceService.filterTransactionsForMonth(
      transactions,
      DateTime(2026, 5),
    );
    final previousMonth = MonthlyFinanceService.filterTransactionsForMonth(
      transactions,
      DateTime(2026, 4),
    );
    final twoMonthsAgo = MonthlyFinanceService.filterTransactionsForMonth(
      transactions,
      DateTime(2026, 3),
    );

    expect(MonthlyFinanceService.calculateBalance(currentMonth), 5082);
    expect(MonthlyFinanceService.calculateBalance(previousMonth), 1530);
    expect(MonthlyFinanceService.calculateBalance(twoMonthsAgo), 3400);
    expect(
      currentMonth.where((transaction) => transaction.isIncome),
      hasLength(1),
    );
    expect(
      transactions.where((transaction) => transaction.type == Transaction.typeExpense),
      hasLength(7),
    );
  });
}
