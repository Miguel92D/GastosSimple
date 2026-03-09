import '../repositories/budget_repository.dart';

class BudgetController {
  final BudgetRepository repository;

  BudgetController({required this.repository});

  static final BudgetController instance = BudgetController(
    repository: BudgetRepositoryImpl(),
  );

  Future<Map<String, double>> loadAllLimits(List<String> categories) async {
    Map<String, double> limits = {};
    for (var cat in categories) {
      limits[cat] = await repository.getLimit(cat);
    }
    return limits;
  }

  Future<Map<String, double>> loadAllSpent(List<String> categories) async {
    Map<String, double> spent = {};
    for (var cat in categories) {
      spent[cat] = await repository.getSpent(cat);
    }
    return spent;
  }

  Future<void> updateLimit(String category, double amount) async {
    await repository.setLimit(category, amount);
  }
}
