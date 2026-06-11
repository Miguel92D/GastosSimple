import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/features/goals/models/savings_goal.dart';

void main() {
  group('SavingsGoal.progress', () {
    SavingsGoal buildGoal({
      required double currentAmount,
      required double targetAmount,
    }) {
      return SavingsGoal(
        name: 'Test',
        currentAmount: currentAmount,
        targetAmount: targetAmount,
        targetDate: DateTime(2030),
        icon: '💰',
        createdAt: DateTime(2026),
      );
    }

    test('returns 0 when targetAmount is 0 (no NaN)', () {
      final goal = buildGoal(currentAmount: 100, targetAmount: 0);
      expect(goal.progress, 0.0);
      expect(goal.progress.isNaN, isFalse);
    });

    test('clamps progress to 1 when saved exceeds target', () {
      final goal = buildGoal(currentAmount: 250, targetAmount: 100);
      expect(goal.progress, 1.0);
    });

    test('computes partial progress', () {
      final goal = buildGoal(currentAmount: 25, targetAmount: 100);
      expect(goal.progress, 0.25);
    });
  });

  group('SavingsGoal.fromMap', () {
    test('parses int amounts from JSON backups without crashing', () {
      final goal = SavingsGoal.fromMap({
        'id': 1,
        'name': 'Auto',
        'currentAmount': 500, // int, como llega de jsonDecode
        'targetAmount': 10000, // int
        'targetDate': DateTime(2030).toIso8601String(),
        'icon': '🚗',
        'createdAt': DateTime(2026).toIso8601String(),
      });

      expect(goal.currentAmount, 500.0);
      expect(goal.targetAmount, 10000.0);
    });

    test('uses fallback icon when missing', () {
      final goal = SavingsGoal.fromMap({
        'id': 2,
        'name': 'Viaje',
        'currentAmount': 0,
        'targetAmount': 100,
        'targetDate': DateTime(2030).toIso8601String(),
      });

      expect(goal.icon, isNotEmpty);
    });
  });
}
