import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/services/daily_allowance_service.dart';

Transaction t(String type, double amount, DateTime d) =>
    Transaction(amount: amount, category: 'X', type: type, date: d);

void main() {
  // 21/10: quedan 11 días contando hoy (octubre tiene 31).
  final now = DateTime(2026, 10, 21, 15);

  test('reparte lo que queda entre los días restantes', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: [
        t('ingreso', 1000000, DateTime(2026, 10, 1)),
        t('gasto', 450000, DateTime(2026, 10, 10)),
        t('gasto', 10000, DateTime(2026, 10, 21, 9)), // hoy
      ],
      recurring: [
        {
          'type': 'gasto',
          'amount': 110000.0,
          'frequency': 'monthly',
          'next_date': DateTime(2026, 10, 28).toIso8601String(),
          'anchor_day': 28,
        },
      ],
      now: now,
    );
    expect(a.state, AllowanceState.ok);
    expect(a.daysLeft, 11);
    // (1.000.000 - 450.000 - 110.000) / 11 = 40.000
    expect(a.perDay, closeTo(40000, 0.01));
    expect(a.spentToday, 10000);
    expect(a.leftToday, closeTo(30000, 0.01));
  });

  test('sin ingresos en el mes', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: [t('gasto', 5000, DateTime(2026, 10, 3))],
      recurring: const [],
      now: now,
    );
    expect(a.state, AllowanceState.noIncome);
  });

  test('gastó más de lo que entró', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: [
        t('ingreso', 100000, DateTime(2026, 10, 1)),
        t('gasto', 120000, DateTime(2026, 10, 5)),
      ],
      recurring: const [],
      now: now,
    );
    expect(a.state, AllowanceState.overspent);
    expect(a.perDay, 0);
  });

  test('con presupuesto mensual se ignoran los ingresos', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: [
        t('ingreso', 5000000, DateTime(2026, 10, 1)), // no cuenta
        t('gasto', 300000, DateTime(2026, 10, 5)),
      ],
      recurring: [
        {
          'type': 'gasto',
          'amount': 80000.0,
          'frequency': 'monthly',
          'next_date': DateTime(2026, 10, 25).toIso8601String(),
        },
      ],
      now: now,
      monthlyBudget: 600000,
    );
    expect(a.usesBudget, isTrue);
    // (600.000 - 300.000 - 80.000) / 11 = 20.000
    expect(a.perDay, closeTo(20000, 0.01));
  });

  test('presupuesto sin ingresos cargados no muestra "sin ingresos"', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: const [],
      recurring: const [],
      now: now,
      monthlyBudget: 110000,
    );
    expect(a.state, AllowanceState.ok);
    expect(a.perDay, closeTo(10000, 0.01));
  });

  test('ingreso fijo pendiente cuenta como disponible', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: const [],
      recurring: [
        {
          'type': 'ingreso',
          'amount': 220000.0,
          'frequency': 'monthly',
          'next_date': DateTime(2026, 10, 30).toIso8601String(),
        },
      ],
      now: now,
    );
    expect(a.state, AllowanceState.ok);
    expect(a.perDay, closeTo(20000, 0.01));
  });

  test('las cuotas que ya se completaron no cuentan', () {
    final a = DailyAllowanceService.compute(
      monthTransactions: [t('ingreso', 110000, DateTime(2026, 10, 1))],
      recurring: [
        {
          'type': 'gasto',
          'amount': 50000.0,
          'frequency': 'monthly',
          'next_date': DateTime(2026, 10, 25).toIso8601String(),
          'installments_total': 3,
          'installments_paid': 3,
        },
      ],
      now: now,
    );
    expect(a.pendingFixedExpenses, 0);
  });
}
