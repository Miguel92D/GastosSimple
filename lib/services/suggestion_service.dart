import '../features/transactions/models/transaction.dart';
import '../features/transactions/repositories/transaction_repository.dart';

class SuggestionService {
  static final SuggestionService instance = SuggestionService._init();
  SuggestionService._init();

  Future<List<String>> getSuggestions() async {
    final now = DateTime.now();
    final List<Transaction> currentTransactions =
        await TransactionRepository.getTransactionsInMonth(month: now);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final List<Transaction> lastTransactions =
        await TransactionRepository.getTransactionsInMonth(month: lastMonth);

    List<String> suggestions = [];

    if (currentTransactions.isEmpty) {
      return [
        "¡Empieza a registrar tus gastos para recibir consejos de ahorro!",
      ];
    }

    // 1. Analyze categories with most spending
    Map<String, double> categories = {};
    for (var m in currentTransactions.where((e) => e.type == 'gasto')) {
      categories[m.category] = (categories[m.category] ?? 0) + m.amount;
    }

    if (categories.isNotEmpty) {
      var sortedCategories = categories.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      var topCategory = sortedCategories.first;
      if (topCategory.value > 0) {
        suggestions.add(
          "Podrías ahorrar \$${(topCategory.value * 0.1).toStringAsFixed(0)} al mes reduciendo un 10% en ${topCategory.key}.",
        );
      }
    }

    // 2. Comparison with last month
    if (lastTransactions.isNotEmpty) {
      double totalCurrent = currentTransactions
          .where((m) => m.type == 'gasto')
          .fold(0, (sum, m) => sum + m.amount);
      double totalLast = lastTransactions
          .where((m) => m.type == 'gasto')
          .fold(0, (sum, m) => sum + m.amount);

      if (totalCurrent < totalLast) {
        suggestions.add(
          "¡Genial! Este mes estás gastando menos que el anterior.",
        );
      } else if (totalCurrent > totalLast * 1.2) {
        suggestions.add(
          "Tus gastos han aumentado considerablemente respecto al mes pasado.",
        );
      }
    }

    // 3. Subscription/Recurring check
    int recurringCount = currentTransactions.where((m) => m.isRecurring).length;
    if (recurringCount > 5) {
      suggestions.add(
        "Tienes varias suscripciones activas. ¿Has revisado si las usas todas?",
      );
    }

    // Default if few suggestions
    if (suggestions.length < 2) {
      suggestions.add(
        "Establecer un presupuesto diario te ayudará a ahorrar más rápido.",
      );
    }

    return suggestions;
  }
}
