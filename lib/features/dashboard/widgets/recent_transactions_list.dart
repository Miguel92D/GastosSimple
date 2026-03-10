import 'package:flutter/material.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/widgets/transaction_history_list.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onRefresh;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "ÚLTIMOS MOVIMIENTOS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white54,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TransactionHistoryList(
            transactions: transactions,
            onRefresh: onRefresh,
          ),
        ),
      ],
    );
  }
}
