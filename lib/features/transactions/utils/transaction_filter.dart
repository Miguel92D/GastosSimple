import '../models/transaction.dart';

enum TypeFilter { all, expense, income }

enum PeriodFilter { all, thisMonth, lastMonth, last3Months, specificMonth }

/// Filtros del historial. Se aplican en memoria sobre el historial completo
/// (datos locales): no hay que volver a consultar la base con cada tecla.
class TransactionFilter {
  final TypeFilter type;
  final PeriodFilter period;
  final Set<String> categories; // vacío = todas
  final String query;

  /// Mes usado cuando [period] es [PeriodFilter.specificMonth] (ej. al venir
  /// desde Estadísticas de un mes anterior).
  final DateTime? month;

  const TransactionFilter({
    this.type = TypeFilter.all,
    this.period = PeriodFilter.all,
    this.categories = const {},
    this.query = '',
    this.month,
  });

  bool get isActive =>
      type != TypeFilter.all ||
      period != PeriodFilter.all ||
      categories.isNotEmpty ||
      query.trim().isNotEmpty;

  TransactionFilter copyWith({
    TypeFilter? type,
    PeriodFilter? period,
    Set<String>? categories,
    String? query,
    DateTime? month,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      period: period ?? this.period,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      month: month ?? this.month,
    );
  }

  /// [localize] traduce el nombre de categoría guardado (ej. "Comida") al
  /// idioma de la app, para que la búsqueda encuentre "Food" en inglés.
  List<Transaction> apply(
    List<Transaction> items, {
    required DateTime now,
    String Function(String category)? localize,
  }) {
    final range = _range(now);
    final q = _normalize(query.trim());
    final qDigits = query.replaceAll(RegExp(r'[^0-9]'), '');

    return items.where((t) {
      if (type == TypeFilter.expense && !t.isExpense) return false;
      if (type == TypeFilter.income && !t.isIncome) return false;
      if (categories.isNotEmpty && !categories.contains(t.category)) {
        return false;
      }
      if (range != null &&
          (t.date.isBefore(range.$1) || !t.date.isBefore(range.$2))) {
        return false;
      }
      if (q.isNotEmpty) {
        final haystack = _normalize(
          [
            t.category,
            if (localize != null) localize(t.category),
            t.note ?? '',
          ].join(' '),
        );
        // El monto se compara solo por dígitos: "1.530", "1530" y "$1530"
        // encuentran 1530 (antes LIKE sobre un REAL nunca matcheaba).
        final amountDigits = t.amount
            .toStringAsFixed(2)
            .replaceAll(RegExp(r'\.00$'), '')
            .replaceAll(RegExp(r'[^0-9]'), '');
        final matchesText = haystack.contains(q);
        final matchesAmount =
            qDigits.isNotEmpty && amountDigits.contains(qDigits);
        if (!matchesText && !matchesAmount) return false;
      }
      return true;
    }).toList();
  }

  /// [inicio, fin) del período, o null si es "todo".
  (DateTime, DateTime)? _range(DateTime now) {
    switch (period) {
      case PeriodFilter.all:
        return null;
      case PeriodFilter.thisMonth:
        return (
          DateTime(now.year, now.month),
          DateTime(now.year, now.month + 1),
        );
      case PeriodFilter.lastMonth:
        return (
          DateTime(now.year, now.month - 1),
          DateTime(now.year, now.month),
        );
      case PeriodFilter.last3Months:
        return (
          DateTime(now.year, now.month - 2),
          DateTime(now.year, now.month + 1),
        );
      case PeriodFilter.specificMonth:
        final m = month ?? now;
        return (DateTime(m.year, m.month), DateTime(m.year, m.month + 1));
    }
  }

  static String _normalize(String s) {
    const from = 'áéíóúüñÁÉÍÓÚÜÑ';
    const to = 'aeiouunAEIOUUN';
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final i = from.indexOf(ch);
      buffer.write(i >= 0 ? to[i] : ch);
    }
    return buffer.toString().toLowerCase();
  }
}
