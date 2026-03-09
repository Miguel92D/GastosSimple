import '../models/debt.dart';
import '../repositories/debt_repository.dart';

class DebtController {
  final DebtRepository repository;

  DebtController({required this.repository});

  static final DebtController instance = DebtController(
    repository: DebtRepositoryImpl(),
  );

  Future<List<Debt>> loadDebts() async {
    return await repository.getDebts();
  }

  Future<void> saveDebt(Debt debt) async {
    if (debt.id == null) {
      await repository.insertDebt(debt);
    } else {
      await repository.updateDebt(debt);
    }
  }

  Future<void> deleteDebt(int id) async {
    await repository.deleteDebt(id);
  }

  Future<void> makePayment(int id, double amount) async {
    await repository.payDebt(id, amount);
  }
}
