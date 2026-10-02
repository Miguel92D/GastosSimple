import 'recurrence_schedule.dart';

/// Tarjeta de crédito: solo lo necesario para saber cuándo cae una cuota.
class CreditCard {
  final String id;
  final String name;
  final int closingDay; // día de cierre del resumen (1-31)
  final int dueDay; // día de vencimiento (1-31)

  const CreditCard({
    required this.id,
    required this.name,
    required this.closingDay,
    required this.dueDay,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'closingDay': closingDay,
    'dueDay': dueDay,
  };

  factory CreditCard.fromJson(Map<String, dynamic> json) => CreditCard(
    id: json['id'] as String,
    name: json['name'] as String,
    closingDay: json['closingDay'] as int,
    dueDay: json['dueDay'] as int,
  );
}

class CardSchedule {
  CardSchedule._();

  static DateTime _clampedDate(int year, int month, int day) {
    final first = DateTime(year, month, 1); // normaliza mes 13, 0, etc.
    final max = RecurrenceSchedule.daysInMonth(first.year, first.month);
    return DateTime(first.year, first.month, day > max ? max : day);
  }

  /// Vencimiento del resumen en el que entra una compra hecha en [purchase].
  ///
  /// - Si la compra es hasta el día de cierre (inclusive), entra en el
  ///   resumen que cierra ese mes; si no, en el del mes siguiente.
  /// - El vencimiento es el primer [CreditCard.dueDay] posterior al cierre.
  static DateTime firstDueDate(DateTime purchase, CreditCard card) {
    final closingThisMonth =
        _clampedDate(purchase.year, purchase.month, card.closingDay);
    final purchaseDay = DateTime(purchase.year, purchase.month, purchase.day);
    final closing = purchaseDay.isAfter(closingThisMonth)
        ? _clampedDate(purchase.year, purchase.month + 1, card.closingDay)
        : closingThisMonth;

    final dueSameMonth = _clampedDate(closing.year, closing.month, card.dueDay);
    final due = dueSameMonth.isAfter(closing)
        ? dueSameMonth
        : _clampedDate(closing.year, closing.month + 1, card.dueDay);
    // Mediodía: evita que quede "antes" que movimientos del mismo día.
    return DateTime(due.year, due.month, due.day, 12);
  }
}
