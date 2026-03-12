import 'package:flutter/material.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/widgets/transaction_history_list.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            AppLocalizations.of(context)!.recent_movements,
            style: AppTextStyles.subLabel.copyWith(
              color: AppColors.softText.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TransactionHistoryList(
            transactions: transactions,
            onRefresh: onRefresh,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }
}
