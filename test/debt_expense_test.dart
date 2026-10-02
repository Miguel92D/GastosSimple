import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/debts/utils/debt_expense.dart';

void main() {
  test('categoría según el nombre de la deuda', () {
    expect(DebtExpense.categoryFor('Visa Galicia'), 'Tarjeta de Crédito');
    expect(DebtExpense.categoryFor('Tarjeta Naranja'), 'Tarjeta de Crédito');
    expect(DebtExpense.categoryFor('Préstamo personal'), 'Préstamos');
    expect(DebtExpense.categoryFor('Juan'), 'Préstamos');
  });

  test('nota del gasto', () {
    expect(DebtExpense.noteFor(' Visa '), 'Pago: Visa');
  });
}
