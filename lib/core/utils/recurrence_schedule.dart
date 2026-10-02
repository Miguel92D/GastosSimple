/// Cálculo de fechas para movimientos recurrentes.
///
/// Lógica pura (sin base de datos) para poder testearla.
/// - Mensual: respeta el día "ancla" original. Si el mes no tiene ese día
///   (ej. 31 en febrero) usa el último día del mes, pero el mes siguiente
///   vuelve al día ancla. Así un pago del 31/01 cae el 28/02 y el 31/03,
///   en vez de saltar al 03/03 y correrse para siempre.
class RecurrenceSchedule {
  RecurrenceSchedule._();

  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';

  /// Máximo de ocurrencias que se generan de una sola vez al ponerse al día,
  /// para no bloquear la app si una recurrencia diaria quedó años atrás.
  static const int maxCatchUp = 400;

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static DateTime next(DateTime from, String frequency, {int? anchorDay}) {
    switch (frequency) {
      case daily:
        return DateTime(from.year, from.month, from.day + 1, from.hour,
            from.minute, from.second);
      case weekly:
        return DateTime(from.year, from.month, from.day + 7, from.hour,
            from.minute, from.second);
      case monthly:
      default:
        final anchor = anchorDay ?? from.day;
        // DateTime normaliza meses > 12 (ej. mes 13 => enero del año siguiente).
        final firstOfNext = DateTime(from.year, from.month + 1, 1);
        final maxDay = daysInMonth(firstOfNext.year, firstOfNext.month);
        final day = anchor > maxDay ? maxDay : anchor;
        return DateTime(firstOfNext.year, firstOfNext.month, day, from.hour,
            from.minute, from.second);
    }
  }

  /// Todas las fechas pendientes (<= [now]) empezando por [nextDate], y la
  /// próxima fecha futura en la que debe quedar la recurrencia.
  static ({List<DateTime> due, DateTime upcoming}) dueOccurrences({
    required DateTime nextDate,
    required String frequency,
    required DateTime now,
    int? anchorDay,
  }) {
    final due = <DateTime>[];
    var cursor = nextDate;
    while (!cursor.isAfter(now) && due.length < maxCatchUp) {
      due.add(cursor);
      cursor = next(cursor, frequency, anchorDay: anchorDay);
    }
    return (due: due, upcoming: cursor);
  }
}
