import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/services/stats_service.dart';

Transaction t(String type, double amount, String cat, DateTime d) =>
    Transaction(amount: amount, category: cat, type: type, date: d);

void main() {
  test('agrupa las categorías chicas en Otros', () {
    final sorted = [
      for (var i = 0; i < 8; i++) MapEntry('C$i', (100 - i * 10).toDouble()),
    ];
    final s = StatsService.slices(sorted, maxSlices: 6);
    expect(s.length, 6);
    expect(s.last.key, StatsService.othersKey);
    expect(s.last.categories, ['C5', 'C6', 'C7']);
    expect(s.last.value, 50 + 40 + 30);
  });

  test('sin agrupar si hay pocas', () {
    final s = StatsService.slices([const MapEntry('A', 10.0)]);
    expect(s.single.key, 'A');
  });

  test('tendencia de 6 meses incluye meses vacíos y cruza el año', () {
    final history = [
      t('ingreso', 1000, 'Salario', DateTime(2026, 1, 5)),
      t('gasto', 300, 'Comida', DateTime(2026, 1, 20)),
      t('gasto', 200, 'Comida', DateTime(2025, 11, 2)),
    ];
    final trend = StatsService.monthlyTrend(
      history,
      endMonth: DateTime(2026, 2),
    );
    expect(trend.length, 6);
    expect(trend.first.month, DateTime(2025, 9));
    expect(trend.last.month, DateTime(2026, 2));
    final jan = trend[4];
    expect(jan.income, 1000);
    expect(jan.expense, 300);
    expect(jan.saving, 700);
    expect(trend[2].expense, 200); // noviembre
  });
}
