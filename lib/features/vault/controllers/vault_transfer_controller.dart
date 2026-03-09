import '../../transactions/models/transaction.dart';
import '../../transactions/controllers/transaction_controller.dart';

class VaultTransferController {
  static Future<void> moveToVault(Transaction mov) async {
    if (mov.id == null) return;

    final updatedMov = mov.copyWith(isSecret: 1);
    await TransactionController.updateTransaction(updatedMov);
  }

  static Future<void> moveToNormal(Transaction mov) async {
    if (mov.id == null) return;

    final updatedMov = mov.copyWith(isSecret: 0);
    await TransactionController.updateTransaction(updatedMov);
  }
}
