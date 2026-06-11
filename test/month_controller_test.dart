import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/state/month_controller.dart';

void main() {
  test('normalizes the selected month to year and month only', () {
    final controller = MonthController(
      initialMonth: DateTime(2026, 5, 21, 18, 30),
    );

    expect(controller.selectedMonth, DateTime(2026, 5));
  });

  test('navigates between months without advancing into the future', () {
    final controller = MonthController(initialMonth: DateTime(2026, 5, 21));
    final today = DateTime(2026, 5, 21);

    controller.goToPreviousMonth();
    expect(controller.selectedMonth, DateTime(2026, 4));
    expect(controller.canGoNext(now: today), isTrue);

    controller.goToNextMonth(now: today);
    expect(controller.selectedMonth, DateTime(2026, 5));
    expect(controller.canGoNext(now: today), isFalse);

    controller.goToNextMonth(now: today);
    expect(controller.selectedMonth, DateTime(2026, 5));
  });

  test('selectMonth clamps future months to the current month', () {
    final controller = MonthController(initialMonth: DateTime(2026, 3));

    controller.selectMonth(
      DateTime(2026, 7, 15),
      now: DateTime(2026, 5, 21),
    );

    expect(controller.selectedMonth, DateTime(2026, 5));
  });
}
