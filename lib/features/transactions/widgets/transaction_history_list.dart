import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import 'transaction_tile.dart';

import '../controllers/transaction_controller.dart';
import '../../../core/flow/general_flow_service.dart';
import '../../../core/flow/transaction_flow_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/state/app_state.dart';
import '../../vault/controllers/vault_controller.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onRefresh;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  /// Texto cuando la lista está vacía (ej. "No hay movimientos con estos
  /// filtros"). Si es null se usa el mensaje por defecto.
  final String? emptyMessage;

  const TransactionHistoryList({
    super.key,
    required this.transactions,
    required this.onRefresh,
    this.physics,
    this.padding,
    this.emptyMessage,
  });

  /// Borra y ofrece "Deshacer" (antes un swipe o un toque borraba para
  /// siempre, sin confirmación).
  Future<void> _deleteWithUndo(
    BuildContext context,
    Transaction transaction,
  ) async {
    if (transaction.id == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.read<AppLocaleController>();
    HapticFeedback.mediumImpact();
    await TransactionController.deleteTransaction(transaction.id!);
    onRefresh();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.text('movement_deleted')),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.text('undo'),
            onPressed: () async {
              await TransactionController.restoreDeleted(transaction);
              onRefresh();
            },
          ),
        ),
      );
  }

  void _showOptionsModal(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  AppIcons.edit,
                  color: AppColors.primaryPurple,
                ),
                title: Text(
                  sheetContext.watch<AppLocaleController>().text('edit'),
                  style: AppTextStyles.bodyMain,
                ),
                onTap: () async {
                  GeneralFlowService.goBack();
                  final result = await TransactionFlowService.instance
                      .openEditTransaction(context, transaction);
                  if (result == true) {
                    onRefresh();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  AppIcons.delete,
                  color: AppColors.expenseRed,
                ),
                title: Text(
                  sheetContext.watch<AppLocaleController>().text('delete'),
                  style: AppTextStyles.bodyMain,
                ),
                onTap: () async {
                  GeneralFlowService.goBack();
                  await _deleteWithUndo(context, transaction);
                },
              ),
              ListTile(
                leading: const Icon(
                  AppIcons.close,
                  color: AppColors.softText,
                ),
                title: Text(
                  sheetContext.watch<AppLocaleController>().text('cancel'),
                  style: AppTextStyles.bodyMain,
                ),
                onTap: () => GeneralFlowService.goBack(),
              ),
              const SizedBox(height: 32), // Aumentado para ergonomía
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ??
              context.watch<AppLocaleController>().text(
                'no_movements_recorded',
              ),
          style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
        ),
      );
    }

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, child) {
        return ListView.separated(
          padding: padding ?? EdgeInsets.zero,
          shrinkWrap: physics == const NeverScrollableScrollPhysics(),
          physics: physics ?? const BouncingScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return TransactionTile(
              transaction: transaction,
              hideAmount: AppState.instance.hideBalance,
              onDelete: () => _deleteWithUndo(context, transaction),
              // Deslizar a la derecha manda a la Bóveda, que es Pro: sin Pro
              // el movimiento quedaría escondido donde no se puede abrir.
              // Sacar de la Bóveda siempre se permite.
              onArchive: !AppState.instance.isPro && transaction.isSecret == 0
                  ? null
                  : () async {
                      if (transaction.isSecret == 1) {
                        await VaultController.removeFromVault(transaction);
                      } else {
                        await VaultController.moveToVault(transaction);
                      }
                      onRefresh();
                    },
              onTap: () => _showOptionsModal(context, transaction),
            );
          },
        );
      },
    );
  }
}
