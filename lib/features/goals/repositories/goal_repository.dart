import '../../../database/database_helper.dart';
import '../models/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<void> insertGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(int id);
  Future<void> addToGoal(int id, double amount);
}

class GoalRepositoryImpl implements GoalRepository {
  @override
  Future<List<Goal>> getGoals() async {
    return await DatabaseHelper.instance.getGoals();
  }

  @override
  Future<void> insertGoal(Goal goal) async {
    await DatabaseHelper.instance.insertGoal(goal);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await DatabaseHelper.instance.updateGoal(goal);
  }

  @override
  Future<void> deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
  }

  @override
  Future<void> addToGoal(int id, double amount) async {
    await DatabaseHelper.instance.addToGoal(id, amount);
  }
}
