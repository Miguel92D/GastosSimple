import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/transaction_controller.dart';
import '../../../../core/router/navigation_service.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.edit),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await NavigationService.navigate(
                    "/add",
                    arguments: {'movimientoToEdit': transaction},
                  );
                  if (result == true) {
                    onRefresh();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.delete),
                onTap: () async {
                  Navigator.pop(context);
                  if (transaction.id != null) {
                    await TransactionController.deleteTransaction(
                      transaction.id!,
                    );
                    onRefresh();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: Text(AppLocalizations.of(context)!.cancel),
                onTap: () => Navigator.pop(context),
              ),
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
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
