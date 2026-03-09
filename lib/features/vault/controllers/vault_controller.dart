import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/flow/app_guard.dart';
import '../../transactions/models/transaction.dart';

class VaultController {
  static Future<void> moveToVault(Transaction mov) async {
    await AppGuard.runSafe(() async {
      final updated = mov.copyWith(isSecret: 1);
      await TransactionController.updateTransaction(updated);
    });
  }

  static Future<void> removeFromVault(Transaction mov) async {
    await AppGuard.runSafe(() async {
      final updated = mov.copyWith(isSecret: 0);
      await TransactionController.updateTransaction(updated);
    });
  }

  static Future<List<Transaction>> getVaultTransactions() async {
    return await AppGuard.runSafe(() async {
          return await TransactionController.getVaultHistory();
        }) ??
        [];
  }
}
