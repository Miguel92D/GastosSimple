import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/money.dart';
import '../controllers/transaction_controller.dart';
import '../models/recurring_payment.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import 'package:gastos_simple/core/ui/widgets/app_amount.dart';
import 'package:gastos_simple/core/ui/widgets/app_empty_state.dart';
import 'package:gastos_simple/core/ui/widgets/app_list_row.dart';
import 'package:gastos_simple/core/ui/widgets/app_sheet.dart';

/// Pagos e ingresos fijos (alquiler, suscripciones, sueldo...) y planes de
/// cuotas. Se crean desde "Nuevo movimiento" activando "Repetir" o
/// "En cuotas".
class RecurringScreen extends StatefulWidget {
  final bool isVault;

  const RecurringScreen({super.key, this.isVault = false});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  List<RecurringPayment> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await TransactionController.getRecurringPayments(
        isVault: widget.isVault,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading recurring payments: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _frequencyLabel(AppLocaleController l10n, String frequency) {
    switch (frequency) {
      case 'daily':
        return l10n.text('freq_daily');
      case 'weekly':
        return l10n.text('freq_weekly');
      default:
        return l10n.text('freq_monthly');
    }
  }

  Future<void> _showActions(RecurringPayment item) async {
    final l10n = context.read<AppLocaleController>();
    final action = await AppSheet.show<String>(
      context,
      horizontalPadding: 0,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetOption(
            icon: AppIcons.edit,
            label: l10n.text('recurring_change_amount'),
            onTap: () => Navigator.pop(ctx, 'amount'),
          ),
          AppSheetOption(
            icon: AppIcons.stopRepeat,
            color: AppColors.expenseRed,
            tintLabel: true,
            label: l10n.text('recurring_cancel'),
            onTap: () => Navigator.pop(ctx, 'cancel'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'amount') await _changeAmount(item);
    if (action == 'cancel') await _confirmCancel(item);
  }

  Future<void> _changeAmount(RecurringPayment item) async {
    final l10n = context.read<AppLocaleController>();
    final controller = TextEditingController(
      text: CurrencyHelper.formatAmountForInput(item.amount),
    );
    final newAmount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('recurring_change_amount')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                prefixText: '${CurrencyHelper.getSymbol(ctx)} ',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.text('recurring_change_amount_hint').toUpperCase(),
              style: AppTextStyles.subLabel,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () {
              final value = CurrencyHelper.parseAmount(controller.text);
              if (value != null && Money.toCents(value) > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: Text(l10n.text('save')),
          ),
        ],
      ),
    );
    // Liberar después de la animación de cierre del diálogo.
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    if (newAmount != null) {
      HapticFeedback.lightImpact();
      await TransactionController.updateRecurringAmount(item.id, newAmount);
    }
  }

  Future<void> _confirmCancel(RecurringPayment item) async {
    final l10n = context.read<AppLocaleController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('recurring_cancel_title')),
        content: Text(
          l10n.text(
            item.isInstallment
                ? 'installments_cancel_body'
                : 'recurring_cancel_body',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            child: Text(l10n.text('recurring_cancel')),
          ),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await TransactionController.cancelRecurring(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('recurring_title'),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? _buildEmpty(l10n)
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                _buildSummary(l10n),
                const SizedBox(height: AppSpacing.lg),
                for (final item in _items) ...[
                  _buildItem(l10n, item),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }

  Widget _buildEmpty(AppLocaleController l10n) {
    return AppEmptyState(
      icon: AppIcons.recurring,
      text: l10n.text('recurring_empty'),
    );
  }

  String _money(double v) => AppState.instance.hideBalance
      ? '••••••'
      : CurrencyHelper.format(v, context);

  Widget _buildSummary(AppLocaleController l10n) {
    final installmentsLeft = Money.sum(
      _items.where((i) => i.isInstallment).map((i) => i.remainingAmount),
    );
    return Column(
      children: [
        _buildMonthlySummary(l10n),
        if (Money.toCents(installmentsLeft) > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  AppIcons.installments,
                  color: AppColors.expenseRed,
                  size: AppIconSize.normal,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.text('installments_total_left', {
                      'amount': _money(installmentsLeft),
                    }),
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonthlySummary(AppLocaleController l10n) {
    final expense = Money.sum(
      _items.where((i) => i.isExpense).map((i) => i.monthlyEquivalent),
    );
    final income = Money.sum(
      _items.where((i) => !i.isExpense).map((i) => i.monthlyEquivalent),
    );

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _summaryColumn(
              l10n.text('recurring_monthly_expense'),
              expense,
              AppColors.expenseRed,
            ),
          ),
          Expanded(
            child: _summaryColumn(
              l10n.text('recurring_monthly_income'),
              income,
              AppColors.incomeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.subLabel),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _money(value),
          style: AppTextStyles.titleMain.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildItem(AppLocaleController l10n, RecurringPayment item) {
    final color = item.isExpense ? AppColors.expenseRed : AppColors.incomeGreen;
    final next = DateFormat('d MMM', l10n.locale).format(item.nextDate);
    final title = (item.note != null && item.note!.trim().isNotEmpty)
        ? item.note!
        : L10nHelper.getLocalizedCategory(context, item.category);
    final when = item.isInstallment
        ? l10n.text('installments_progress', {
            'k': item.nextInstallment.toString(),
            'n': item.installmentsTotal.toString(),
          })
        : _frequencyLabel(l10n, item.frequency);

    return AppListRow(
      onTap: () => _showActions(item),
      icon: item.isInstallment ? AppIcons.installments : AppIcons.recurring,
      iconColor: color,
      title: title,
      subtitle: '$when · ${l10n.text('recurring_next', {'d': next})}',
      extra: [
        if (item.isInstallment)
          Text(
            l10n.text('installments_remaining', {
              'amount': _money(item.remainingAmount),
            }),
            style: AppTextStyles.rowSubtitle,
          ),
      ],
      trailing: AppAmount.list(value: item.amount, color: color),
    );
  }
}
