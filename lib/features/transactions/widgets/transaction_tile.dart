import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../models/transaction.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/category_icons.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.isIncome;
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
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: amountColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              CategoryIcons.of(widget.transaction.category),
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
                  DateFormat(
                    'd MMM, yyyy',
                    context.read<AppLocaleController>().locale,
                  ).format(widget.transaction.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softText.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // El monto se achica antes que cortarse con "…".
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.hideAmount
                        ? '••••••'
                        : '$amountPrefix${CurrencyHelper.format(widget.transaction.amount, context)}',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: amountColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                if (widget.transaction.note != null &&
                    widget.transaction.note!.isNotEmpty)
                  Text(
                    widget.transaction.note!,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
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
                        color: AppColors.primaryPurple.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        widget.transaction.isSecret == 1
                            ? AppIcons.vaultLeave
                            : AppIcons.vault,
                        color: AppColors.textPrimary,
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
                        color: AppColors.expenseRed.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        AppIcons.delete,
                        color: AppColors.textPrimary,
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
