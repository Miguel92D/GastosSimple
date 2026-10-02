import 'transaction.dart';

/// Fila de `recurring_transactions` (pago fijo / suscripción / ingreso fijo
/// / plan de cuotas).
class RecurringPayment {
  final int id;
  final double amount;
  final String category;
  final String type;
  final String? note;
  final String frequency; // daily | weekly | monthly
  final DateTime nextDate;
  final bool isSecret;

  /// Compra en cuotas: total de cuotas y cuántas ya se registraron.
  final int? installmentsTotal;
  final int installmentsPaid;
  final double? installmentsTotalAmount;

  const RecurringPayment({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.note,
    required this.frequency,
    required this.nextDate,
    required this.isSecret,
    this.installmentsTotal,
    this.installmentsPaid = 0,
    this.installmentsTotalAmount,
  });

  factory RecurringPayment.fromMap(Map<String, Object?> map) {
    return RecurringPayment(
      id: map['id'] as int,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: Transaction.normalizeType(map['type'] as String?),
      note: map['note'] as String?,
      frequency: map['frequency'] as String,
      nextDate: DateTime.parse(map['next_date'] as String),
      isSecret: ((map['is_secret'] as int?) ?? 0) == 1,
      installmentsTotal: map['installments_total'] as int?,
      installmentsPaid: (map['installments_paid'] as int?) ?? 0,
      installmentsTotalAmount:
          (map['installments_total_amount'] as num?)?.toDouble(),
    );
  }

  bool get isExpense => type == Transaction.typeExpense;

  bool get isInstallment => installmentsTotal != null;

  /// Próxima cuota a registrar (1-based).
  int get nextInstallment => installmentsPaid + 1;

  int get installmentsLeft =>
      isInstallment ? installmentsTotal! - installmentsPaid : 0;

  /// Lo que falta pagar del plan de cuotas.
  double get remainingAmount => installmentsTotalAmount != null
      ? installmentsTotalAmount! - amount * installmentsPaid
      : amount * installmentsLeft;

  /// Cuánto representa por mes, para comparar diarios/semanales/mensuales.
  double get monthlyEquivalent {
    switch (frequency) {
      case 'daily':
        return amount * 30.44;
      case 'weekly':
        return amount * 4.345;
      default:
        return amount;
    }
  }
}
