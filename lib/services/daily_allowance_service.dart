import '../core/utils/installment_plan.dart';
import '../core/utils/money.dart';
import '../core/utils/recurrence_schedule.dart';
import '../features/transactions/models/transaction.dart';

enum AllowanceState { ok, overspent, noIncome }

class DailyAllowance {
  final AllowanceState state;

  /// Lo que podés gastar por día desde hoy hasta fin de mes (fijado al
  /// inicio del día: gastar hoy no lo achica, solo achica [leftToday]).
  final double perDay;
  final double spentToday;
  final double leftToday;

  /// Disponible para el resto del mes (incluido hoy) antes de lo gastado hoy.
  final double available;
  final int daysLeft; // incluye hoy
  final double pendingFixedExpenses;

  /// true si el cálculo usa el presupuesto mensual del usuario en vez de
  /// los ingresos del mes.
  final bool usesBudget;
  final double base;

  const DailyAllowance({
    required this.state,
    required this.perDay,
    required this.spentToday,
    required this.leftToday,
    required this.available,
    required this.daysLeft,
    required this.pendingFixedExpenses,
    this.usesBudget = false,
    this.base = 0,
  });
}

/// "¿Cuánto puedo gastar por día?" con lo que entró este mes (o con el
/// presupuesto mensual, si el usuario definió uno).
///
/// disponible = base (ingresos del mes + ingresos fijos que faltan cobrar,
///              o el presupuesto mensual)
///            − gastos del mes ANTERIORES a hoy
///            − gastos fijos (y cuotas) que faltan pagar este mes
/// por día    = disponible / días que quedan (incluido hoy)
class DailyAllowanceService {
  DailyAllowanceService._();

  static DailyAllowance compute({
    required List<Transaction> monthTransactions,
    required List<Map<String, Object?>> recurring,
    required DateTime now,
    double? monthlyBudget,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));
    final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
    final daysLeft =
        RecurrenceSchedule.daysInMonth(now.year, now.month) - now.day + 1;

    var income = 0.0;
    var spentBeforeToday = 0.0;
    var spentToday = 0.0;
    for (final t in monthTransactions) {
      if (t.date.year != now.year || t.date.month != now.month) continue;
      if (!t.date.isBefore(startOfTomorrow)) continue; // fecha futura
      if (t.isIncome) {
        income = Money.round(income + t.amount);
      } else if (t.date.isBefore(today)) {
        spentBeforeToday = Money.round(spentBeforeToday + t.amount);
      } else {
        spentToday = Money.round(spentToday + t.amount);
      }
    }

    var pendingIncome = 0.0;
    var pendingExpense = 0.0;
    for (final r in recurring) {
      final schedule = RecurrenceSchedule.dueOccurrences(
        nextDate: DateTime.parse(r['next_date'] as String),
        frequency: r['frequency'] as String,
        now: monthEnd,
        anchorDay: r['anchor_day'] as int?,
      );
      // Solo lo que vence DESPUÉS de hoy; lo de hoy ya se generó como
      // movimiento al abrir la app.
      final due = InstallmentPlan.cap(schedule.due, r);
      final amount = _pendingAmount(r, due, startOfTomorrow);
      if (Transaction.normalizeType(r['type'] as String?) ==
          Transaction.typeIncome) {
        pendingIncome = Money.round(pendingIncome + amount);
      } else {
        pendingExpense = Money.round(pendingExpense + amount);
      }
    }

    // Con presupuesto mensual definido, la base es ese tope (sirve a quien
    // vive de ahorros o cobra por fuera de la app). Si no, lo que entró.
    final budget = monthlyBudget ?? 0;
    final usesBudget = budget > 0;
    final base = usesBudget ? budget : income + pendingIncome;
    final available = Money.round(base - spentBeforeToday - pendingExpense);

    if (Money.toCents(base) <= 0) {
      return DailyAllowance(
        state: AllowanceState.noIncome,
        perDay: 0,
        spentToday: spentToday,
        leftToday: 0,
        available: available,
        daysLeft: daysLeft,
        pendingFixedExpenses: pendingExpense,
        usesBudget: usesBudget,
        base: base,
      );
    }

    // A centavos (D-005): así "te quedan hoy" nunca muestra -0,00 ni
    // marca exceso por un error de punto flotante.
    final perDay = Money.toCents(available) > 0
        ? Money.round(available / daysLeft)
        : 0.0;
    return DailyAllowance(
      state: Money.toCents(available) - Money.toCents(spentToday) <= 0
          ? AllowanceState.overspent
          : AllowanceState.ok,
      perDay: perDay,
      spentToday: spentToday,
      leftToday: Money.round(perDay - spentToday),
      available: available,
      daysLeft: daysLeft,
      pendingFixedExpenses: pendingExpense,
      usesBudget: usesBudget,
      base: base,
    );
  }

  /// Lo que falta cobrar/pagar de una recurrencia después de hoy. En un plan
  /// de cuotas cada cuota usa su monto real: la última absorbe el redondeo
  /// (igual que `processRecurringTransactions`), así lo que se descuenta
  /// acá es lo mismo que después aparece en Movimientos.
  static double _pendingAmount(
    Map<String, Object?> r,
    List<DateTime> due,
    DateTime startOfTomorrow,
  ) {
    final perInstallment = (r['amount'] as num).toDouble();
    final total = r['installments_total'] as int?;
    final paid = (r['installments_paid'] as int?) ?? 0;
    var cents = 0;
    for (var i = 0; i < due.length; i++) {
      if (due[i].isBefore(startOfTomorrow)) continue;
      final amount = total == null
          ? perInstallment
          : InstallmentPlan.amountFor(
              k: paid + i + 1,
              count: total,
              perInstallment: perInstallment,
              totalAmount: (r['installments_total_amount'] as num?)?.toDouble(),
            );
      cents += Money.toCents(amount);
    }
    return Money.fromCents(cents);
  }
}
