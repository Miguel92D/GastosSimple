import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';

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
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_bus;
      case 'ocio':
        return Icons.sports_esports;
      case 'salud':
        return Icons.local_hospital;
      case 'educación':
        return Icons.school;
      case 'salario':
        return Icons.attach_money;
      case 'venta':
        return Icons.storefront;
      case 'regalo':
        return Icons.card_giftcard;
      case 'inversión':
        return Icons.trending_up;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'ingreso';
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountPrefix = isIncome ? '+' : '-';

    Widget tile = InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Section
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: amountColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(transaction.date),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
                    fontSize: 17,
                    color: amountColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (transaction.isRecurring)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.repeat_rounded,
                      size: 14,
                      color: Colors.blue[300],
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
        key: Key(transaction.id.toString()),
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
            color: Colors.orange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.visibility_off, color: Colors.white),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: tile,
      ),
    );
  }
}
