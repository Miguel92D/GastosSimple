/// Cómo se registra el pago de una deuda como gasto.
class DebtExpense {
  DebtExpense._();

  static const String prefKey = 'debt_payment_records_expense';

  static const List<String> _cardWords = [
    'tarjeta', 'visa', 'master', 'amex', 'american', 'cabal', 'naranja',
    'credito', 'crédito', 'card',
  ];

  /// "Tarjeta de Crédito" si el nombre parece una tarjeta; si no,
  /// "Préstamos". Ambas son categorías de gasto existentes.
  static String categoryFor(String debtName) {
    final name = debtName.toLowerCase();
    return _cardWords.any(name.contains) ? 'Tarjeta de Crédito' : 'Préstamos';
  }

  static String noteFor(String debtName) => 'Pago: ${debtName.trim()}';
}
