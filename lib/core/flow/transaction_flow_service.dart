import 'package:flutter/material.dart';
import '../router/navigation_service.dart';
import '../../features/transactions/controllers/transaction_controller.dart';
import '../../features/transactions/models/transaction.dart';
import '../state/app_mode_controller.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';

class TransactionFlowService {
  static final TransactionFlowService instance = TransactionFlowService._();
  TransactionFlowService._();

  Future<void> startQuickEntry(
    BuildContext context, {
    bool isVault = false,
    String? type,
    Map<String, dynamic>? arguments,
  }) async {
    AppModeController.instance.setVaultMode(isVault);

    // Merge provided arguments with defaults
    final Map<String, dynamic> navArgs = {'isVault': isVault, 'type': type};
    if (arguments != null) {
      navArgs.addAll(arguments);
    }

    await NavigationService.navigate('/add', arguments: navArgs);
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
    Object? goal,
    double goalAmount = 0,
    bool isFromQuickEntry = false,
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

      // After saving, redirect based on origin
      if (isFromQuickEntry) {
        // If we started from Quick Entry, we want to go straight to the dashboard
        if (transaction.isSecret == 1) {
          NavigationService.navigateAndRemoveUntil('/vault');
        } else {
          NavigationService.navigateAndRemoveUntil('/dashboard');
        }
      } else {
        // If we were already in a dashboard, just go back
        NavigationService.goBack();
      }
    } catch (e) {
      debugPrint('Error saving transaction flow: $e');
      if (context.mounted) {
        final l10n = context.read<AppLocaleController>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.text('error_saving_transaction'))),
        );
      }
    }
  }
}
