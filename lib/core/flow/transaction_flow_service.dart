import 'package:flutter/material.dart';
import '../router/navigation_service.dart';
import '../../features/transactions/controllers/transaction_controller.dart';
import '../../features/transactions/models/transaction.dart';
import '../state/app_mode_controller.dart';

import '../../features/dashboard/screens/home_screen.dart';

class TransactionFlowService {
  static final TransactionFlowService instance = TransactionFlowService._();
  TransactionFlowService._();

  Future<void> startQuickEntry(
    BuildContext context, {
    bool isVault = false,
    String? type,
  }) async {
    AppModeController.instance.setVaultMode(isVault);
    await NavigationService.navigate(
      '/add',
      arguments: {'isVault': isVault, 'type': type},
    );
  }

  Future<dynamic> openEditTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    return await NavigationService.navigate(
      '/add',
      arguments: {'movimientoToEdit': transaction},
    );
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
      }

      // After saving, navigate only to the Dashboard and clear stack
      NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
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
