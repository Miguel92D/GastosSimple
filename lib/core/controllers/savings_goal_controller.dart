import 'package:flutter/material.dart';
import '../../features/goals/models/goal.dart';
import '../../features/goals/repositories/goal_repository.dart';

class SavingsGoalController extends ChangeNotifier {
  final GoalRepository _repository;
  List<Goal> _goals = [];
  bool _isLoading = false;

  SavingsGoalController({required GoalRepository repository}) : _repository = repository;

  static final SavingsGoalController instance = SavingsGoalController(
    repository: GoalRepositoryImpl(),
  );

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  double get totalSaved {
    return _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  int get activeGoalsCount {
    return _goals.where((g) => g.currentAmount < g.targetAmount).length;
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await _repository.getGoals();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createGoal(Goal goal) async {
    await _repository.insertGoal(goal);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _repository.updateGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    await _repository.deleteGoal(id);
    await loadGoals();
  }

  Future<void> addMoneyToGoal(int id, double amount) async {
    await _repository.addToGoal(id, amount);
    await loadGoals();
  }

  double calculateProgress(Goal goal) {
    if (goal.targetAmount <= 0) return 0.0;
    return (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
  }

  double calculateMonthlySaving(Goal goal) {
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    if (remainingAmount <= 0) return 0.0;

    final today = DateTime.now();
    final targetDate = goal.targetDate;

    // Calculate months remaining
    int monthsRemaining = (targetDate.year - today.year) * 12 + (targetDate.month - today.month);
    
    // If target date is in the same month but after today, or in the past
    if (monthsRemaining <= 0) return remainingAmount;

    return remainingAmount / monthsRemaining;
  }
}
