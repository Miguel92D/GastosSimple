import '../core/utils/money.dart';
import '../features/transactions/models/transaction.dart';

class ChartSlice {
  /// Categoría guardada, o [StatsService.othersKey] para el grupo "Otros".
  final String key;
  final double value;
  final List<String> categories; // las que agrupa (1 salvo en "Otros")

  const ChartSlice(this.key, this.value, this.categories);
}

class MonthTotals {
  final DateTime month;
  final double income;
  final double expense;

  const MonthTotals(this.month, this.income, this.expense);

  double get saving => Money.round(income - expense);
}

/// Cálculos de Estadísticas, sin UI (testeables).
class StatsService {
  StatsService._();

  static const String othersKey = '__others__';

  /// Gasto por categoría, de mayor a menor.
  static List<MapEntry<String, double>> expensesByCategory(
    List<Transaction> items,
  ) {
    final map = <String, double>{};
    for (final t in items) {
      if (!t.isExpense) continue;
      map[t.category] = Money.round((map[t.category] ?? 0) + t.amount);
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Porciones del anillo: las [maxSlices] - 1 mayores y el resto en "Otros"
  /// (un anillo con 12 porciones finitas no se puede leer ni tocar).
  static List<ChartSlice> slices(
    List<MapEntry<String, double>> sorted, {
    int maxSlices = 6,
  }) {
    if (sorted.length <= maxSlices) {
      return [for (final e in sorted) ChartSlice(e.key, e.value, [e.key])];
    }
    final top = sorted.take(maxSlices - 1);
    final rest = sorted.skip(maxSlices - 1).toList();
    return [
      for (final e in top) ChartSlice(e.key, e.value, [e.key]),
      ChartSlice(
        othersKey,
        rest.fold(0.0, (s, e) => Money.round(s + e.value)),
        rest.map((e) => e.key).toList(),
      ),
    ];
  }

  /// Ingresos y gastos de los [months] meses que terminan en [endMonth].
  static List<MonthTotals> monthlyTrend(
    List<Transaction> history, {
    required DateTime endMonth,
    int months = 6,
  }) {
    final result = <MonthTotals>[];
    for (var i = months - 1; i >= 0; i--) {
      final start = DateTime(endMonth.year, endMonth.month - i);
      final end = DateTime(start.year, start.month + 1);
      var income = 0.0;
      var expense = 0.0;
      for (final t in history) {
        if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
        if (t.isIncome) {
          income = Money.round(income + t.amount);
        } else {
          expense = Money.round(expense + t.amount);
        }
      }
      result.add(MonthTotals(start, income, expense));
    }
    return result;
  }
}
