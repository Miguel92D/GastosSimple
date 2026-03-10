import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/design/app_colors.dart';

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
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+' : '-';

    Widget tile = GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 20,
        child: Row(
          children: [
            // Icon Section
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: amountColor.withValues(alpha: 0.2)),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: amountColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Info Section
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(transaction.date),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hideAmount
                      ? '••••••'
                      : '$amountPrefix${CurrencyHelper.format(transaction.amount, context)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: amountColor,
                  ),
                ),
                if (transaction.isRecurring)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.repeat_rounded,
                      size: 12,
                      color: Colors.white38,
                    ),
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
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.archive_rounded, color: Colors.blue),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.red),
        ),
        child: tile,
      ),
    );
  }
}
