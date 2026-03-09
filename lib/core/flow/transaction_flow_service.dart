import 'package:flutter/material.dart';
import '../router/navigation_service.dart';
import '../../features/transactions/controllers/transaction_controller.dart';
import '../../features/transactions/models/transaction.dart';
import '../state/app_mode_controller.dart';

class TransactionFlowService {
  static final TransactionFlowService instance = TransactionFlowService._();
  TransactionFlowService._();

  Future<void> startQuickEntry(
    BuildContext context, {
    bool isVault = false,
  }) async {
    AppModeController.instance.setVaultMode(isVault);
    await NavigationService.navigate('/add', arguments: {'isVault': isVault});
  }

  Future<void> saveTransaction(
    BuildContext context,
    Transaction transaction, {
    bool isRecurring = false,
    String frequency = 'monthly',
    Object?
    goal, // Keeping it dynamic to avoid extra imports if possible, or use Goal type
    double goalAmount = 0,
  }) async {
    try {
      if (transaction.id != null) {
        await TransactionController.updateTransaction(transaction);
      } else {
        await TransactionController.addTransaction(transaction);

        if (isRecurring) {
          await TransactionController.addRecurringTransaction(
            transaction,
            frequency,
          );
        }

        // We can handle goal logic here if needed, or in TransactionController
      }

      // TransactionController already handles Notification via TransactionNotifier

      // Final navigation based on mode
      if (transaction.isSecret == 1) {
        NavigationService.navigateAndRemoveUntil('/vault');
      } else {
        NavigationService.navigateAndRemoveUntil('/dashboard');
      }
    } catch (e) {
      debugPrint('Error saving transaction flow: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la transacción')),
        );
      }
    }
  }
}
