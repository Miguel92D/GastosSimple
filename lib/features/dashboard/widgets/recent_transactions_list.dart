import 'package:flutter/material.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/widgets/transaction_history_list.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            "ÚLTIMOS MOVIMIENTOS",
            style: AppTextStyles.subLabel.copyWith(
              color: AppColors.softText.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TransactionHistoryList(
            transactions: transactions,
            onRefresh: onRefresh,
          ),
        ),
      ],
    );
  }
}
