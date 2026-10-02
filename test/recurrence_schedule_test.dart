import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/recurrence_schedule.dart';

void main() {
  group('RecurrenceSchedule.next (mensual)', () {
    test('31/01 cae el 28/02 y vuelve al 31/03 (no se corre)', () {
      final feb = RecurrenceSchedule.next(DateTime(2026, 1, 31), 'monthly',
          anchorDay: 31);
      expect(feb, DateTime(2026, 2, 28));
      final mar = RecurrenceSchedule.next(feb, 'monthly', anchorDay: 31);
      expect(mar, DateTime(2026, 3, 31));
      final abr = RecurrenceSchedule.next(mar, 'monthly', anchorDay: 31);
      expect(abr, DateTime(2026, 4, 30));
    });

    test('año bisiesto: 29/02', () {
      expect(
        RecurrenceSchedule.next(DateTime(2028, 1, 30), 'monthly', anchorDay: 30),
        DateTime(2028, 2, 29),
      );
    });

    test('diciembre pasa a enero del año siguiente', () {
      expect(
        RecurrenceSchedule.next(DateTime(2026, 12, 15), 'monthly'),
        DateTime(2027, 1, 15),
      );
    });

    test('sin anchorDay (filas viejas) usa el día de la fecha', () {
      expect(
        RecurrenceSchedule.next(DateTime(2026, 5, 10), 'monthly'),
        DateTime(2026, 6, 10),
      );
    });
  });

  test('diario y semanal', () {
    expect(RecurrenceSchedule.next(DateTime(2026, 2, 28), 'daily'),
        DateTime(2026, 3, 1));
    expect(RecurrenceSchedule.next(DateTime(2026, 12, 28), 'weekly'),
        DateTime(2027, 1, 4));
  });

  group('dueOccurrences', () {
    test('genera todas las ocurrencias atrasadas', () {
      final r = RecurrenceSchedule.dueOccurrences(
        nextDate: DateTime(2026, 1, 5),
        frequency: 'monthly',
        now: DateTime(2026, 4, 10),
      );
      expect(r.due, [
        DateTime(2026, 1, 5),
        DateTime(2026, 2, 5),
        DateTime(2026, 3, 5),
        DateTime(2026, 4, 5),
      ]);
      expect(r.upcoming, DateTime(2026, 5, 5));
    });

    test('nada pendiente si la fecha es futura', () {
      final r = RecurrenceSchedule.dueOccurrences(
        nextDate: DateTime(2026, 5, 1),
        frequency: 'monthly',
        now: DateTime(2026, 4, 10),
      );
      expect(r.due, isEmpty);
      expect(r.upcoming, DateTime(2026, 5, 1));
    });

    test('tope de seguridad en recurrencias diarias muy atrasadas', () {
      final r = RecurrenceSchedule.dueOccurrences(
        nextDate: DateTime(2020, 1, 1),
        frequency: 'daily',
        now: DateTime(2026, 1, 1),
      );
      expect(r.due.length, RecurrenceSchedule.maxCatchUp);
    });
  });
}
