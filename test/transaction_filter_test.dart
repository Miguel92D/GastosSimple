import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/features/transactions/utils/transaction_filter.dart';

Transaction t(String type, double amount, String cat, DateTime d,
        {String? note}) =>
    Transaction(amount: amount, category: cat, type: type, date: d, note: note);

void main() {
  final now = DateTime(2026, 10, 2);
  final items = [
    t('gasto', 1530, 'Comida', DateTime(2026, 10, 1), note: 'Almuerzo'),
    t('gasto', 900.5, 'Transporte', DateTime(2026, 9, 15)),
    t('ingreso', 500000, 'Salario', DateTime(2026, 9, 1)),
    t('gasto', 20000, 'Salud', DateTime(2026, 6, 10), note: 'Farmacia'),
  ];

  test('sin filtros devuelve todo', () {
    expect(const TransactionFilter().apply(items, now: now).length, 4);
  });

  test('tipo y período', () {
    final f = const TransactionFilter(
      type: TypeFilter.expense,
      period: PeriodFilter.last3Months,
    );
    expect(f.apply(items, now: now).map((e) => e.category),
        ['Comida', 'Transporte']);
    expect(
      const TransactionFilter(period: PeriodFilter.lastMonth)
          .apply(items, now: now)
          .length,
      2,
    );
  });

  test('mes específico', () {
    final f = TransactionFilter(
      period: PeriodFilter.specificMonth,
      month: DateTime(2026, 6),
    );
    expect(f.apply(items, now: now).single.category, 'Salud');
  });

  test('categorías', () {
    final f = const TransactionFilter(categories: {'Salud', 'Salario'});
    expect(f.apply(items, now: now).length, 2);
  });

  test('busca monto con o sin separador de miles', () {
    expect(const TransactionFilter(query: '1.530').apply(items, now: now).length, 1);
    expect(const TransactionFilter(query: '1530').apply(items, now: now).length, 1);
  });

  test('busca nota sin importar tildes ni mayúsculas, y categoría traducida', () {
    expect(const TransactionFilter(query: 'FARMACIA').apply(items, now: now).length, 1);
    final r = const TransactionFilter(query: 'food').apply(
      items,
      now: now,
      localize: (c) => c == 'Comida' ? 'Food' : c,
    );
    expect(r.single.category, 'Comida');
  });
}
