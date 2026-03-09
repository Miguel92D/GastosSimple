import '../models/goal.dart';
import '../repositories/goal_repository.dart';

class GoalController {
  final GoalRepository repository;

  GoalController({required this.repository});

  static final GoalController instance = GoalController(
    repository: GoalRepositoryImpl(),
  );

  Future<List<Goal>> loadGoals() async {
    return await repository.getGoals();
  }

  Future<void> saveGoal(Goal goal) async {
    if (goal.id == null) {
      await repository.insertGoal(goal);
    } else {
      await repository.updateGoal(goal);
    }
  }

  Future<void> deleteGoal(int id) async {
    await repository.deleteGoal(id);
  }

  Future<void> addFunds(int id, double amount) async {
    await repository.addToGoal(id, amount);
  }
}
