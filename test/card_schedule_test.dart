import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/card_schedule.dart';
import 'package:gastos_simple/core/utils/installment_plan.dart';

CreditCard card(int closing, int due) =>
    CreditCard(id: '1', name: 'Visa', closingDay: closing, dueDay: due);

void main() {
  group('CardSchedule.firstDueDate', () {
    // Cierre 25, vence 5 del mes siguiente (el caso típico).
    test('compra antes del cierre: vence el mes siguiente', () {
      expect(CardSchedule.firstDueDate(DateTime(2026, 10, 2), card(25, 5)),
          DateTime(2026, 11, 5, 12));
    });
    test('compra el día del cierre entra en ese resumen', () {
      expect(CardSchedule.firstDueDate(DateTime(2026, 10, 25, 18), card(25, 5)),
          DateTime(2026, 11, 5, 12));
    });
    test('compra después del cierre: pasa al resumen siguiente', () {
      expect(CardSchedule.firstDueDate(DateTime(2026, 10, 26), card(25, 5)),
          DateTime(2026, 12, 5, 12));
    });
    test('vencimiento en el mismo mes del cierre', () {
      expect(CardSchedule.firstDueDate(DateTime(2026, 10, 2), card(3, 15)),
          DateTime(2026, 10, 15, 12));
      expect(CardSchedule.firstDueDate(DateTime(2026, 10, 20), card(3, 15)),
          DateTime(2026, 11, 15, 12));
    });
    test('cierre 31 en febrero y cruce de año', () {
      expect(CardSchedule.firstDueDate(DateTime(2026, 2, 10), card(31, 10)),
          DateTime(2026, 3, 10, 12));
      expect(CardSchedule.firstDueDate(DateTime(2026, 12, 28), card(25, 5)),
          DateTime(2027, 2, 5, 12));
    });
  });

  test('la última cuota absorbe el redondeo', () {
    final per = InstallmentPlan.perInstallment(100, 3); // 33.33
    expect(InstallmentPlan.amountFor(k: 1, count: 3, perInstallment: per, totalAmount: 100), 33.33);
    expect(InstallmentPlan.amountFor(k: 3, count: 3, perInstallment: per, totalAmount: 100), 33.34);
    // Planes viejos sin total guardado: cuota fija.
    expect(InstallmentPlan.amountFor(k: 3, count: 3, perInstallment: per), 33.33);
  });
}
