import '../features/transactions/models/transaction.dart';

class MonthlyAnalysisData {
  final double income;
  final double expenses;
  final double balance;
  final double previousMonthExpenses;
  final double expenseDifference;
  final bool improvedVsPreviousMonth;
  final String topSpendingDay;
  final double dailyAverage;

  const MonthlyAnalysisData({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.previousMonthExpenses,
    required this.expenseDifference,
    required this.improvedVsPreviousMonth,
    required this.topSpendingDay,
    required this.dailyAverage,
  });
}

class MonthlyFinanceService {
  static DateTime normalizeMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static DateTime nextMonth(DateTime month) {
    final normalizedMonth = normalizeMonth(month);
    return DateTime(normalizedMonth.year, normalizedMonth.month + 1);
  }

  static bool isSameMonth(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month;
  }

  static int daysInMonth(DateTime month) {
    final normalizedMonth = normalizeMonth(month);
    return DateTime(normalizedMonth.year, normalizedMonth.month + 1, 0).day;
  }

  static List<Transaction> filterTransactionsForMonth(
    List<Transaction> transactions,
    DateTime month,
  ) {
    final startOfMonth = normalizeMonth(month);
    final startOfNextMonth = nextMonth(startOfMonth);

    return transactions
        .where(
          (transaction) =>
              !transaction.date.isBefore(startOfMonth) &&
              transaction.date.isBefore(startOfNextMonth),
        )
        .toList();
  }

  static double calculateIncome(List<Transaction> transactions) {
    return transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  static double calculateExpenses(List<Transaction> transactions) {
    return transactions
        .where((transaction) => transaction.isExpense)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  static double calculateBalance(List<Transaction> transactions) {
    return calculateIncome(transactions) - calculateExpenses(transactions);
  }

  static MonthlyAnalysisData buildAnalysis({
    required List<Transaction> currentMonthTransactions,
    required List<Transaction> previousMonthTransactions,
    required DateTime selectedMonth,
    DateTime? now,
  }) {
    final income = calculateIncome(currentMonthTransactions);
    final expenses = calculateExpenses(currentMonthTransactions);
    final previousMonthExpenses = calculateExpenses(previousMonthTransactions);
    final expenseDifference = expenses - previousMonthExpenses;
    final dailySpending = <int, double>{};

    for (final transaction in currentMonthTransactions) {
      if (!transaction.isExpense) continue;

      final day = transaction.date.day;
      dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount;
    }

    var topDay = 0;
    var topAmount = 0.0;
    dailySpending.forEach((day, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topDay = day;
      }
    });

    final normalizedSelectedMonth = normalizeMonth(selectedMonth);
    final today = now ?? DateTime.now();
    final divisor = isSameMonth(normalizedSelectedMonth, today)
        ? today.day
        : daysInMonth(normalizedSelectedMonth);

    return MonthlyAnalysisData(
      income: income,
      expenses: expenses,
      balance: income - expenses,
      previousMonthExpenses: previousMonthExpenses,
      expenseDifference: expenseDifference,
      improvedVsPreviousMonth: expenseDifference <= 0,
      topSpendingDay: topDay > 0 ? '$topDay' : '-',
      dailyAverage: divisor > 0 ? expenses / divisor : 0,
    );
  }
}
