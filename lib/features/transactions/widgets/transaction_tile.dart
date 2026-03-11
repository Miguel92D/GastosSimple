import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';

class TransactionTile extends StatefulWidget {
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

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent < -120 && widget.onDelete != null) {
      widget.onDelete!();
    } else if (_dragExtent > 120 && widget.onArchive != null) {
      widget.onArchive!();
    }

    _animation = Tween<double>(
      begin: _dragExtent,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward(from: 0).then((_) {
      _dragExtent = 0;
    });
  }

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
    final isIncome = widget.transaction.type == 'ingreso';
    final amountColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final amountPrefix = isIncome ? '+' : '-';

    Widget tileContent = GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: amountColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              _getCategoryIcon(widget.transaction.category),
              color: amountColor,
              size: 18,
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
                    widget.transaction.category,
                  ),
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM, yyyy').format(widget.transaction.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softText.withOpacity(0.3),
                    fontSize: 10,
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
                widget.hideAmount
                    ? '••••••'
                    : '$amountPrefix${CurrencyHelper.format(widget.transaction.amount, context)}',
                style: AppTextStyles.cardTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: amountColor,
                ),
              ),
              if (widget.transaction.note != null &&
                  widget.transaction.note!.isNotEmpty)
                Text(
                  widget.transaction.note!,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );

    if (widget.onDelete == null && widget.onArchive == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: GestureDetector(onTap: widget.onTap, child: tileContent),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentOffset = _controller.isAnimating
            ? _animation.value
            : _dragExtent;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Private Vault Background (Left side - Swipe Right)
                if (currentOffset > 0)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.primaryPurple,
                        size: 28,
                      ),
                    ),
                  ),
                // Delete Background (Right side)
                if (currentOffset < 0)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppColors.expenseRed.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: AppColors.expenseRed,
                        size: 28,
                      ),
                    ),
                  ),
                // Moving Card
                GestureDetector(
                  onTap: widget.onTap,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: Transform.translate(
                    offset: Offset(currentOffset, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: tileContent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
