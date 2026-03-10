import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onTap;
  final bool hideAmount;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onArchive,
    this.onTap,
    this.hideAmount = false,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'ocio':
        return Icons.sports_esports_rounded;
      case 'salud':
        return Icons.local_hospital_rounded;
      case 'educación':
        return Icons.school_rounded;
      case 'salario':
        return Icons.payments_rounded;
      case 'venta':
        return Icons.storefront_rounded;
      case 'regalo':
        return Icons.card_giftcard_rounded;
      case 'inversión':
        return Icons.trending_up_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'ingreso';
    final amountColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final amountPrefix = isIncome ? '+' : '-';

    Widget tile = GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 20,
        glowColor: amountColor.withOpacity(0.04),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: amountColor.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: amountColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10nHelper.getLocalizedCategory(
                      context,
                      transaction.category,
                    ),
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM, yyyy').format(transaction.date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.softText.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hideAmount
                      ? '••••••'
                      : '$amountPrefix${CurrencyHelper.format(transaction.amount, context)}',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: amountColor,
                  ),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Text(
                    transaction.note!,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onDelete == null && onArchive == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: tile,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: Key(transaction.id?.toString() ?? UniqueKey().toString()),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd && onArchive != null) {
            onArchive!();
          } else if (onDelete != null) {
            onDelete!();
          }
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.archive_rounded, color: AppColors.blue),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.expenseRed.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.expenseRed),
        ),
        child: tile,
      ),
    );
  }
}
