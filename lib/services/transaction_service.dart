import '../features/transactions/models/transaction.dart';

class TransactionService {
  static double calculateIncome(List<Transaction> transactions) {
    return transactions
        .where((m) => m.type == 'ingreso')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  static double calculateExpenses(List<Transaction> transactions) {
    return transactions
        .where((m) => m.type == 'gasto')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  static double calculateBalance(List<Transaction> transactions) {
    final income = calculateIncome(transactions);
    final expenses = calculateExpenses(transactions);
    return income - expenses;
  }

  static Transaction? parseQuickInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;

    final amountPart = parts[0];
    String type = 'gasto';
    String amountString = amountPart;

    if (amountPart.startsWith('+')) {
      type = 'ingreso';
      amountString = amountPart.substring(1);
    } else if (amountPart.startsWith('-')) {
      type = 'gasto';
      amountString = amountPart.substring(1);
    } else {
      type = 'gasto';
    }

    final amount = double.tryParse(amountString.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return null;

    String category = 'Otros';
    if (parts.length > 1) {
      category = parts.sublist(1).join(' ');
      category = category.isNotEmpty
          ? '${category[0].toUpperCase()}${category.substring(1).toLowerCase()}'
          : 'Otros';
    }

    return Transaction(
      amount: amount,
      category: category,
      type: type,
      date: DateTime.now(),
    );
  }
}
