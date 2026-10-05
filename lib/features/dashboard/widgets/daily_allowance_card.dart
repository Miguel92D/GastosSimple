import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../database/database_helper.dart';
import '../../../services/daily_allowance_service.dart';
import '../../../services/monthly_budget_service.dart';
import '../../transactions/controllers/transaction_controller.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import 'package:gastos_simple/core/ui/widgets/app_progress_bar.dart';

/// "Podés gastar hoy": cuánto queda por día con lo que entró este mes (o
/// con el presupuesto mensual). Se carga sola (no depende del período del
/// dashboard).
class DailyAllowanceCard extends StatefulWidget {
  const DailyAllowanceCard({super.key});

  @override
  State<DailyAllowanceCard> createState() => _DailyAllowanceCardState();
}

class _DailyAllowanceCardState extends State<DailyAllowanceCard> {
  DailyAllowance? _data;

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
      final now = DateTime.now();
      final month = await TransactionController.getTransactionsInMonth(
        month: now,
      );
      final recurring = await DatabaseHelper.instance
          .getRecurringTransactions();
      final budget = await MonthlyBudgetService.get();
      if (!mounted) return;
      setState(() {
        _data = DailyAllowanceService.compute(
          monthTransactions: month,
          recurring: recurring,
          now: now,
          monthlyBudget: budget,
        );
      });
    } catch (e) {
      debugPrint('Error loading daily allowance: $e');
    }
  }

  String _money(double v) => AppState.instance.hideBalance
      ? '••••••'
      : CurrencyHelper.format(v, context);

  /// Texto del desglose. Se arma dentro del builder del diálogo porque
  /// [_money] usa context.watch (solo válido durante un build).
  String _breakdownBody(AppLocaleController l10n, DailyAllowance d) {
    if (d.state == AllowanceState.noIncome) {
      return l10n.text('allowance_how_no_income');
    }
    return l10n.text(
      d.usesBudget ? 'allowance_how_body_budget' : 'allowance_how_body',
      {
        'budget': _money(d.base),
        'available': _money(d.available),
        'fixed': _money(d.pendingFixedExpenses),
        'days': d.daysLeft.toString(),
        'perDay': _money(d.perDay),
      },
    );
  }

  Future<void> _showBreakdown(AppLocaleController l10n, DailyAllowance d) async {
    final editBudget = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('allowance_how_title')),
        content: Text(_breakdownBody(l10n, d), style: AppTextStyles.bodyMain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.text('budget_monthly_button')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.text('allowance_got_it')),
          ),
        ],
      ),
    );
    if (editBudget == true && mounted) await _editBudget(l10n);
  }

  Future<void> _editBudget(AppLocaleController l10n) async {
    final current = await MonthlyBudgetService.get();
    if (!mounted) return;
    final controller = TextEditingController(
      text: current == null ? '' : CurrencyHelper.formatAmountForInput(current),
    );
    // null = cancelar, 0 = quitar presupuesto, > 0 = guardar.
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('budget_monthly_title')),
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
              l10n.text('budget_monthly_hint'),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 0),
              style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
              child: Text(l10n.text('budget_monthly_remove')),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () {
              final v = CurrencyHelper.parseAmount(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: Text(l10n.text('save')),
          ),
        ],
      ),
    );
    // Liberar después de la animación de cierre del diálogo.
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    if (result == null) return;
    await MonthlyBudgetService.set(result);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    context.watch<AppState>(); // ocultar saldos
    final d = _data;
    if (d == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: GestureDetector(
        onTap: () => _showBreakdown(l10n, d),
        child: GlassCard(
          borderRadius: AppRadius.lg,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: switch (d.state) {
            AllowanceState.noIncome => _buildMessage(
              AppIcons.tip,
              AppColors.softText,
              l10n.text('allowance_no_income'),
            ),
            AllowanceState.overspent => _buildMessage(
              AppIcons.warning,
              AppColors.expenseRed,
              l10n.text(
                d.usesBudget
                    ? 'allowance_overspent_budget'
                    : 'allowance_overspent',
              ),
            ),
            AllowanceState.ok => _buildOk(l10n, d),
          },
        ),
      ),
    );
  }

  Widget _buildMessage(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildOk(AppLocaleController l10n, DailyAllowance d) {
    final over = d.leftToday < 0;
    final color = over ? AppColors.expenseRed : AppColors.incomeGreen;
    final progress = d.perDay > 0
        ? (d.spentToday / d.perDay).clamp(0.0, 1.0)
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.text(over ? 'allowance_over_today' : 'allowance_today')
                    .toUpperCase(),
                style: AppTextStyles.subLabel.copyWith(letterSpacing: 1.2),
              ),
            ),
            Icon(
              AppIcons.info,
              size: 16,
              color: AppColors.softText.withValues(alpha: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _money(d.leftToday.abs()),
            maxLines: 1,
            style: AppTextStyles.balanceAmount.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(value: progress, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.text(
            d.usesBudget ? 'allowance_detail_budget' : 'allowance_detail',
            {
              'perDay': _money(d.perDay),
              'days': d.daysLeft.toString(),
              'budget': _money(d.base),
            },
          ),
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
