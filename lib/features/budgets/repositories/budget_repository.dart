import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/database_helper.dart';
import '../../transactions/models/transaction.dart';

abstract class BudgetRepository {
  Future<double> getLimit(String category);
  Future<void> setLimit(String category, double amount);
  Future<double> getSpent(String category);
}

class BudgetRepositoryImpl implements BudgetRepository {
  @override
  Future<double> getLimit(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('budget_$category') ?? 0.0;
  }

  @override
  Future<void> setLimit(String category, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_$category', amount);
  }

  @override
  Future<double> getSpent(String category) async {
    final List<Transaction> transactions = await DatabaseHelper.instance
        .getTransactionsInMonth();

    return transactions
        .where((t) => t.type == 'gasto' && t.category == category)
        .fold<double>(0.0, (sum, item) => sum + item.amount);
  }
}
