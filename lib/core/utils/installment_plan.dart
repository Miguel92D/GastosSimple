import 'money.dart';

/// Compras en cuotas (tarjeta de crédito).
///
/// Se modelan como una recurrencia mensual con un total de cuotas. Todas
/// las cuotas las genera `processRecurringTransactions` cuando llega su
/// fecha (la primera: fecha de compra o vencimiento de la tarjeta), hasta
/// completar el plan. Así no se crean movimientos con fecha futura y cada
/// cuota impacta en el mes que corresponde (dashboard, estadísticas,
/// proyección, gasto diario).
class InstallmentPlan {
  InstallmentPlan._();

  static const List<int> presets = [3, 6, 12, 18, 24];
  static const int maxInstallments = 60;

  /// Monto de cada cuota, redondeado a centavos.
  static double perInstallment(double total, int count) =>
      Money.round(total / count);

  /// Monto de la cuota [k] de [count]. La última absorbe la diferencia de
  /// redondeo para que la suma dé exactamente [totalAmount]
  /// (ej. 100 en 3 cuotas: 33,33 + 33,33 + 33,34).
  static double amountFor({
    required int k,
    required int count,
    required double perInstallment,
    double? totalAmount,
  }) {
    if (k < count || totalAmount == null) return perInstallment;
    // En centavos enteros: 100 - 33,33 × 2 da 33,34 justo (D-005).
    return Money.fromCents(
      Money.toCents(totalAmount) - Money.toCents(perInstallment) * (count - 1),
    );
  }

  /// Nota de la cuota k de n. [base] es la nota que escribió el usuario.
  static String noteFor(String? base, int k, int n) {
    final b = base?.trim() ?? '';
    return b.isEmpty ? 'Cuota $k/$n' : '$b ($k/$n)';
  }

  /// Cuántas de las ocurrencias vencidas todavía corresponden al plan.
  static int remaining({required int? total, required int? paid}) {
    if (total == null) return 1 << 30; // recurrencia sin fin
    final left = total - (paid ?? 0);
    return left < 0 ? 0 : left;
  }

  /// Recorta la lista de fechas a las cuotas que faltan (si es un plan).
  static List<T> cap<T>(List<T> due, Map<String, Object?> row) {
    final left = remaining(
      total: row['installments_total'] as int?,
      paid: row['installments_paid'] as int?,
    );
    return due.length <= left ? due : due.sublist(0, left);
  }
}
