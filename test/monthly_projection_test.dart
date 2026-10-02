import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/services/monthly_projection_service.dart';

Transaction gasto(DateTime d, double amount, {bool recurring = false}) =>
    Transaction(
      amount: amount,
      category: 'X',
      type: 'gasto',
      date: d,
      isRecurring: recurring,
    );

void main() {
  test('alquiler el día 1 no se multiplica por los días del mes', () {
    final now = DateTime(2026, 9, 2, 12);
    // Historial de agosto: gasto variable de 10.000 por día.
    final history = [
      for (var d = 1; d <= 31; d++) gasto(DateTime(2026, 8, d, 10), 10000),
      gasto(DateTime(2026, 8, 1, 9), 500000), // alquiler agosto
      gasto(DateTime(2026, 9, 1, 9), 500000), // alquiler septiembre
      gasto(DateTime(2026, 9, 1, 10), 10000),
      gasto(DateTime(2026, 9, 2, 10), 10000),
    ];
    final p = MonthlyProjectionService.compute(
      history: history,
      recurring: const [],
      now: now,
    );
    expect(p.insufficientData, isFalse);
    expect(p.spentSoFar, 520000);
    expect(p.dailyVariableRate, closeTo(10000, 1));
    // 520.000 + 28 días × 10.000 = 800.000 (la regla de tres daba 7.800.000)
    expect(p.projectedExpense, closeTo(800000, 100));
  });

  test('con menos de 7 días de datos no extrapola', () {
    final now = DateTime(2026, 9, 2, 12);
    final p = MonthlyProjectionService.compute(
      history: [gasto(DateTime(2026, 9, 1), 500000)],
      recurring: [
        {
          'type': 'gasto',
          'amount': 20000.0,
          'frequency': 'monthly',
          'next_date': DateTime(2026, 9, 15).toIso8601String(),
          'anchor_day': 15,
        },
      ],
      now: now,
    );
    expect(p.insufficientData, isTrue);
    expect(p.projectedExpense, 520000);
  });

  test('recurrencias de ingreso no suman al gasto', () {
    final now = DateTime(2026, 9, 2, 12);
    final p = MonthlyProjectionService.compute(
      history: const [],
      recurring: [
        {
          'type': 'ingreso',
          'amount': 1000000.0,
          'frequency': 'monthly',
          'next_date': DateTime(2026, 9, 10).toIso8601String(),
        },
      ],
      now: now,
    );
    expect(p.pendingRecurring, 0);
  });
}
