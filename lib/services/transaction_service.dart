import '../features/transactions/models/transaction.dart';
import 'currency_service.dart';

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
    }

    // Support for currency symbols (e.g. $100, USD100, S/100)
    // We remove all non-numeric characters except for the decimal separator
    // But first we handle common symbols that might be used as prefixes
    final currentSymbol = CurrencyService.instance.currencySymbol;
    if (amountString.startsWith(currentSymbol)) {
      amountString = amountString.substring(currentSymbol.length);
    }

    // Clean any remaining non-numeric characters (except , and .)
    amountString = amountString.replaceAll(RegExp(r'[^0-9,.]'), '');

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
