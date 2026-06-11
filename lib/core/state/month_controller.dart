import 'package:flutter/material.dart';

class MonthController extends ChangeNotifier {
  static final MonthController instance = MonthController();

  MonthController({DateTime? initialMonth})
      : _selectedMonth = normalizeMonth(initialMonth ?? DateTime.now());

  DateTime _selectedMonth;

  DateTime get selectedMonth => _selectedMonth;

  static DateTime normalizeMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static bool isSameMonth(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month;
  }

  bool isCurrentMonth({DateTime? now}) {
    return isSameMonth(_selectedMonth, normalizeMonth(now ?? DateTime.now()));
  }

  bool canGoNext({DateTime? now}) {
    return _selectedMonth.isBefore(normalizeMonth(now ?? DateTime.now()));
  }

  void goToPreviousMonth() {
    _setSelectedMonth(DateTime(_selectedMonth.year, _selectedMonth.month - 1));
  }

  void goToNextMonth({DateTime? now}) {
    if (!canGoNext(now: now)) return;

    final nextMonth = normalizeMonth(
      DateTime(_selectedMonth.year, _selectedMonth.month + 1),
    );
    final currentMonth = normalizeMonth(now ?? DateTime.now());

    _setSelectedMonth(
      nextMonth.isAfter(currentMonth) ? currentMonth : nextMonth,
    );
  }

  void goToCurrentMonth({DateTime? now}) {
    _setSelectedMonth(normalizeMonth(now ?? DateTime.now()));
  }

  void selectMonth(DateTime month, {DateTime? now}) {
    final normalizedMonth = normalizeMonth(month);
    final currentMonth = normalizeMonth(now ?? DateTime.now());

    _setSelectedMonth(
      normalizedMonth.isAfter(currentMonth) ? currentMonth : normalizedMonth,
    );
  }

  void _setSelectedMonth(DateTime month) {
    final normalizedMonth = normalizeMonth(month);
    if (isSameMonth(_selectedMonth, normalizedMonth)) return;

    _selectedMonth = normalizedMonth;
    notifyListeners();
  }
}
