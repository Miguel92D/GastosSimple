import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/transaction_controller.dart';
import '../../../../core/flow/general_flow_service.dart';
import '../../../../core/flow/transaction_flow_service.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/ui/app_text_styles.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onRefresh;

  const TransactionHistoryList({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  void _showOptionsModal(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
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
                leading: const Icon(Icons.edit_rounded, color: AppColors.blue),
                title: Text(
                  AppLocalizations.of(context)!.edit,
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
                  Icons.delete_rounded,
                  color: AppColors.expenseRed,
                ),
                title: Text(
                  AppLocalizations.of(context)!.delete,
                  style: AppTextStyles.bodyMain,
                ),
                onTap: () async {
                  GeneralFlowService.goBack();
                  if (transaction.id != null) {
                    await TransactionController.deleteTransaction(
                      transaction.id!,
                    );
                    onRefresh();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.softText,
                ),
                title: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: AppTextStyles.bodyMain,
                ),
                onTap: () => GeneralFlowService.goBack(),
              ),
              const SizedBox(height: 16),
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
          AppLocalizations.of(context)!.no_movements_recorded,
          style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionTile(
          transaction: transaction,
          onDelete: () async {
            if (transaction.id != null) {
              await TransactionController.deleteTransaction(transaction.id!);
              onRefresh();
            }
          },
          onArchive: () {},
          onTap: () => _showOptionsModal(context, transaction),
        );
      },
    );
  }
}
