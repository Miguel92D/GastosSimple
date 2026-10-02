import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/features/transactions/utils/transaction_csv.dart';

void main() {
  String csv(List<Transaction> items) => TransactionCsv.build(
    items,
    headers: ['Fecha', 'Tipo', 'Categoría', 'Monto', 'Nota'],
    typeLabels: (income: 'Ingreso', expense: 'Gasto'),
    localize: (c) => c == 'Comida' ? 'Comida 🍔' : c,
  );

  test('encabezado, BOM y formato argentino', () {
    final out = csv([
      Transaction(
        amount: 1530.5,
        category: 'Comida',
        type: 'gasto',
        date: DateTime(2026, 10, 2, 9, 5),
        note: 'Almuerzo',
      ),
      Transaction(
        amount: 500000,
        category: 'Salario',
        type: 'ingreso',
        date: DateTime(2026, 10, 1),
      ),
    ]);
    expect(out.startsWith('﻿Fecha;Tipo;Categoría;Monto;Nota\r\n'), isTrue);
    expect(out, contains('02/10/2026 09:05;Gasto;Comida 🍔;-1530,50;Almuerzo\r\n'));
    expect(out, contains('01/10/2026 00:00;Ingreso;Salario;500000,00;\r\n'));
  });

  test('escapa separador, comillas y saltos de línea', () {
    final out = csv([
      Transaction(
        amount: 10,
        category: 'Otros',
        type: 'gasto',
        date: DateTime(2026, 1, 1),
        note: 'a;b "c"\nd',
      ),
    ]);
    expect(out, contains('"a;b ""c""\nd"'));
  });

  test('neutraliza fórmulas en notas', () {
    final out = csv([
      Transaction(
        amount: 10,
        category: 'Otros',
        type: 'gasto',
        date: DateTime(2026, 1, 1),
        note: '=HYPERLINK("x")',
      ),
    ]);
    expect(out, contains("\"'=HYPERLINK(\"\"x\"\")\""));
  });
}
