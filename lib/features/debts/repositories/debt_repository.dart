import '../../../database/database_helper.dart';
import '../models/debt.dart';

abstract class DebtRepository {
  Future<List<Debt>> getDebts();
  Future<void> insertDebt(Debt debt);
  Future<void> updateDebt(Debt debt);
  Future<void> deleteDebt(int id);
  Future<void> payDebt(int id, double amount);
}

class DebtRepositoryImpl implements DebtRepository {
  @override
  Future<List<Debt>> getDebts() async {
    return await DatabaseHelper.instance.getDebts();
  }

  @override
  Future<void> insertDebt(Debt debt) async {
    await DatabaseHelper.instance.insertDebt(debt);
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    await DatabaseHelper.instance.updateDebt(debt);
  }

  @override
  Future<void> deleteDebt(int id) async {
    await DatabaseHelper.instance.deleteDebt(id);
  }

  @override
  Future<void> payDebt(int id, double amount) async {
    await DatabaseHelper.instance.payDebt(id, amount);
  }
}
