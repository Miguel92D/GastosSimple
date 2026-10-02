import '../models/debt.dart';
import '../repositories/debt_repository.dart';
import '../utils/debt_expense.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../transactions/models/transaction.dart';

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

  /// [recordExpenseFor]: si se pasa la deuda, el pago también se registra
  /// como gasto de hoy (para que el balance refleje la plata que salió).
  Future<void> makePayment(
    int id,
    double amount, {
    Debt? recordExpenseFor,
  }) async {
    await repository.payDebt(id, amount);
    final debt = recordExpenseFor;
    if (debt != null) {
      await TransactionController.addTransaction(
        Transaction(
          amount: amount,
          category: DebtExpense.categoryFor(debt.nombre),
          type: Transaction.typeExpense,
          date: DateTime.now(),
          note: DebtExpense.noteFor(debt.nombre),
        ),
      );
    }
  }
}
