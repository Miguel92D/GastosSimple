import '../core/utils/installment_plan.dart';
import '../core/utils/money.dart';
import '../core/utils/recurrence_schedule.dart';
import '../features/transactions/models/transaction.dart';

class MonthlyProjection {
  final double spentSoFar;
  final double projectedExpense;
  final double dailyVariableRate;
  final double pendingRecurring;

  /// true si hay menos de [MonthlyProjectionService.minDaysOfData] días de
  /// historial: no se extrapola, solo se suma lo gastado + recurrencias.
  final bool insufficientData;

  const MonthlyProjection({
    required this.spentSoFar,
    required this.projectedExpense,
    required this.dailyVariableRate,
    required this.pendingRecurring,
    required this.insufficientData,
  });
}

/// Proyección de gasto del mes. Reemplaza la regla de tres anterior
/// (gasto / días transcurridos × días del mes), que con un alquiler pagado
/// el día 1 proyectaba ~15 alquileres el día 2.
///
/// Proyección = gastado este mes
///            + ritmo diario de gasto variable × días restantes
///            + recurrencias de gasto que todavía vencen este mes.
///
/// El ritmo diario sale de los últimos 30 días (no solo del mes en curso)
/// e ignora movimientos recurrentes y gastos puntuales grandes
/// (> [outlierFactor] × la mediana), que no se repiten cada día.
class MonthlyProjectionService {
  MonthlyProjectionService._();

  static const int windowDays = 30;
  static const int minDaysOfData = 7;
  static const double outlierFactor = 3;

  static MonthlyProjection compute({
    required List<Transaction> history,
    required List<Map<String, Object?>> recurring,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(milliseconds: 1));
    final daysRemaining =
        RecurrenceSchedule.daysInMonth(now.year, now.month) - now.day;

    final expenses = history.where((t) => t.isExpense && !t.date.isAfter(now));

    final spentSoFar = expenses
        .where((t) => !t.date.isBefore(monthStart))
        .fold(0.0, (s, t) => Money.round(s + t.amount));

    // Recurrencias de gasto que aún vencen dentro del mes.
    var pendingRecurring = 0.0;
    for (final r in recurring) {
      if (Transaction.normalizeType(r['type'] as String?) !=
          Transaction.typeExpense) {
        continue;
      }
      final schedule = RecurrenceSchedule.dueOccurrences(
        nextDate: DateTime.parse(r['next_date'] as String),
        frequency: r['frequency'] as String,
        now: monthEnd,
        anchorDay: r['anchor_day'] as int?,
      );
      final amount = (r['amount'] as num).toDouble();
      pendingRecurring = Money.round(
        pendingRecurring +
            InstallmentPlan.cap(schedule.due, r)
                    .where((d) => d.isAfter(now))
                    .length *
                amount,
      );
    }

    DateTime? firstExpense;
    for (final t in expenses) {
      if (firstExpense == null || t.date.isBefore(firstExpense)) {
        firstExpense = t.date;
      }
    }
    final daysOfData = firstExpense == null
        ? 0
        : today
                  .difference(DateTime(
                    firstExpense.year,
                    firstExpense.month,
                    firstExpense.day,
                  ))
                  .inDays +
              1;

    if (daysOfData < minDaysOfData) {
      return MonthlyProjection(
        spentSoFar: spentSoFar,
        projectedExpense: Money.round(spentSoFar + pendingRecurring),
        dailyVariableRate: 0,
        pendingRecurring: pendingRecurring,
        insufficientData: true,
      );
    }

    final window = daysOfData < windowDays ? daysOfData : windowDays;
    final windowStart = today.subtract(Duration(days: window - 1));
    final variable = expenses
        .where((t) => !t.isRecurring && !t.date.isBefore(windowStart))
        .map((t) => t.amount)
        .toList();

    final median = _median(variable);
    final variableTotal = variable
        .where((a) => median == 0 || a <= median * outlierFactor)
        .fold(0.0, (s, a) => Money.round(s + a));
    final rate = variableTotal / window;

    return MonthlyProjection(
      spentSoFar: spentSoFar,
      projectedExpense:
          Money.round(spentSoFar + rate * daysRemaining + pendingRecurring),
      dailyVariableRate: rate,
      pendingRecurring: pendingRecurring,
      insufficientData: false,
    );
  }

  static double _median(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
