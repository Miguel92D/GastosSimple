import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/installment_plan.dart';

void main() {
  test('monto por cuota redondeado a centavos', () {
    expect(InstallmentPlan.perInstallment(600000, 6), 100000);
    expect(InstallmentPlan.perInstallment(100, 3), 33.33);
  });

  test('nota de cada cuota', () {
    expect(InstallmentPlan.noteFor('Heladera', 2, 6), 'Heladera (2/6)');
    expect(InstallmentPlan.noteFor(null, 1, 3), 'Cuota 1/3');
    expect(InstallmentPlan.noteFor('  ', 3, 3), 'Cuota 3/3');
  });

  test('recorta las vencidas a las cuotas que faltan', () {
    final due = [1, 2, 3, 4, 5];
    // Plan de 6 con 4 pagadas: solo quedan 2.
    expect(
      InstallmentPlan.cap(due, {'installments_total': 6, 'installments_paid': 4}),
      [1, 2],
    );
    // Recurrencia normal (sin plan): no recorta.
    expect(InstallmentPlan.cap(due, {}), due);
    // Plan completo: nada.
    expect(
      InstallmentPlan.cap(due, {'installments_total': 3, 'installments_paid': 3}),
      isEmpty,
    );
  });
}
