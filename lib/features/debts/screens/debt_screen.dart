import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../../../core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../controllers/debt_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/flow/app_guard.dart';
import '../../../core/flow/premium_flow_service.dart';
import '../../../core/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/debt_expense.dart';
import '../utils/debt_math.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import 'package:gastos_simple/core/ui/widgets/app_round_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_action_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_amount.dart';
import 'package:gastos_simple/core/ui/widgets/app_empty_state.dart';
import 'package:gastos_simple/core/ui/widgets/app_list_row.dart';
import 'package:gastos_simple/core/ui/widgets/app_progress_bar.dart';
import 'package:gastos_simple/core/ui/widgets/app_section_title.dart';
import 'package:gastos_simple/core/ui/widgets/app_sheet.dart';
import 'package:gastos_simple/core/ui/widgets/glass_input.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final _controller = DebtController.instance;
  List<Debt> _debts = [];
  bool _isLoading = true;
  String _selectedStrategy = 'none'; // 'avalanche', 'snowball', 'none'

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    try {
      setState(() => _isLoading = true);
      final debts = await _controller.loadDebts();
      if (mounted) {
        setState(() {
          _debts = debts;
          _sortDebts();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading debts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sortDebts() {
    _debts = DebtMath.sortForStrategy(_debts, _selectedStrategy);
  }

  void _selectStrategy(String strategy) {
    // Los Tips de salida (Avalancha / Bola de nieve) son PRO (P-05).
    if (!AppState.instance.isPro) {
      PremiumFlowService.showUpgradePrompt(context);
      return;
    }
    setState(() {
      _selectedStrategy = strategy;
      _sortDebts();
    });
  }

  String _formatDateShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final parts = dateStr.split('/');
    if (parts.length == 3 && parts[2].length == 4) {
      return '${parts[0].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[2].substring(2)}';
    }
    return dateStr;
  }

  void _showDebtForm({Debt? debt}) {
    final nombreController = TextEditingController(text: debt?.nombre);
    final montoTotalController = TextEditingController(
      text: debt != null
          ? CurrencyHelper.formatAmountForInput(debt.montoTotal)
          : '',
    );
    final pagoMinimoController = TextEditingController(
      text: debt != null
          ? CurrencyHelper.formatAmountForInput(debt.pagoMinimo)
          : '',
    );
    final tasaInteresController = TextEditingController(
      text: debt?.tasaInteres != null ? debt!.tasaInteres!.toString() : '',
    );
    final fechaVencimientoController = TextEditingController(
      text: _formatDateShort(debt?.fechaVencimiento),
    );
    final diaCierreController = TextEditingController(
      text: _formatDateShort(debt?.diaCierre),
    );
    final cuotasTotalesController = TextEditingController(
      text: debt?.cuotasTotales?.toString() ?? '',
    );

    AppSheet.show<void>(
      context,
      builder: (context) {
        final innerL10n = context.read<AppLocaleController>();
        return SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSheetTitle(
                debt == null
                    ? innerL10n.text('new_debt')
                    : innerL10n.text('edit_debt'),
              ),
              _buildField(
                innerL10n.text('debt_name_label'),
                nombreController,
                icon: AppIcons.name,
              ),
              _buildField(
                innerL10n.text('total_amount'),
                montoTotalController,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                icon: AppIcons.wallet,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              _buildField(
                innerL10n.text('min_payment'),
                pagoMinimoController,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                icon: AppIcons.pay,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      innerL10n.text('interest_rate_optional'),
                      tasaInteresController,
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      icon: AppIcons.percent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildField(
                      innerL10n.text('due_day_label'),
                      fechaVencimientoController,
                      keyboard: TextInputType.none,
                      icon: AppIcons.day,
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, fechaVencimientoController),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      innerL10n.text('installments_label'),
                      cuotasTotalesController,
                      keyboard: TextInputType.number,
                      icon: AppIcons.installmentCount,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildField(
                      innerL10n.text('card_closing_label'),
                      diaCierreController,
                      keyboard: TextInputType.none,
                      icon: AppIcons.day,
                      textInputAction: TextInputAction.done,
                      readOnly: true,
                      onTap: () => _selectDate(context, diaCierreController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                onTap: () => _saveDebt(
                  debt,
                  nombreController,
                  montoTotalController,
                  pagoMinimoController,
                  tasaInteresController,
                  fechaVencimientoController,
                  diaCierreController,
                  cuotasTotalesController,
                ),
                color: AppColors.primaryPurple,
                label: innerL10n.text('save_debt'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveDebt(
    Debt? debt,
    TextEditingController nombreController,
    TextEditingController montoTotalController,
    TextEditingController pagoMinimoController,
    TextEditingController tasaInteresController,
    TextEditingController fechaVencimientoController,
    TextEditingController diaCierreController,
    TextEditingController cuotasTotalesController,
  ) async {
    if (nombreController.text.isEmpty || montoTotalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppLocaleController>().text(
              'complete_name_and_amount',
            ),
          ),
        ),
      );
      return;
    }

    final newDebt = Debt(
      id: debt?.id,
      nombre: nombreController.text,
      montoTotal: CurrencyHelper.parseAmount(montoTotalController.text) ?? 0,
      pagoMinimo: CurrencyHelper.parseAmount(pagoMinimoController.text) ?? 0,
      tasaInteres: tasaInteresController.text.isNotEmpty
          ? double.tryParse(tasaInteresController.text.replaceAll(',', '.'))
          : null,
      fechaVencimiento: fechaVencimientoController.text,
      diaCierre: diaCierreController.text.isEmpty
          ? null
          : diaCierreController.text,
      cuotasTotales: int.tryParse(cuotasTotalesController.text),
      cuotasPagadas: debt?.cuotasPagadas,
      montoPagado: debt?.montoPagado ?? 0,
    );

    final success = await AppGuard.runWithFeedback(
      context,
      () => _controller.saveDebt(newDebt),
    );

    if (success && mounted) {
      Navigator.pop(context);
      _loadDebts();
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        final parts = controller.text.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          if (year < 100) year += 2000;
          initialDate = DateTime(year, month, day);
        }
      }
    } catch (_) {
      // Ignore errors and use current date
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (!context.mounted) return;
      final yearShort = picked.year.toString().substring(2);
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/$yearShort";
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
    VoidCallback? onTap,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassInput(
        controller: controller,
        label: label,
        icon: icon,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onTap: onTap,
        readOnly: readOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final totalRemaining = DebtMath.totalRemaining(_debts);
    final priorityDebt = DebtMath.priority(_debts);

    return AppScaffold(
      title: l10n.text('debts'),
      drawer: const AppDrawer(),
      floatingActionButton: _buildAddDebtFab(context),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, // margen de pantalla 24 (D-032)
                AppSpacing.sm,
                AppSpacing.lg,
                120, // lugar para el menú y el + de abajo
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalSummary(context, l10n, totalRemaining),
                  const SizedBox(height: 32),
                  if (_debts.isEmpty)
                    AppEmptyState(
                      icon: AppIcons.debts,
                      text: l10n.text('no_debts_empty'),
                      subtitle: l10n.text('no_debts_subtitle'),
                      actionText: l10n.text('add_first_debt'),
                      onAction: () => _showDebtForm(),
                    )
                  else
                    ..._debts.map((debt) {
                      final isPriority =
                          _selectedStrategy != 'none' && debt == priorityDebt;
                      return _buildDebtItem(
                        context,
                        debt,
                        isPriority: isPriority,
                      );
                    }),
                  const SizedBox(height: 24),
                  _buildStrategySection(context),
                ],
              ),
            ),
    );
  }

  Future<void> _showPaymentModal(Debt debt) async {
    final amountController = TextEditingController(
      text: !debt.isPaid
          ? CurrencyHelper.formatAmountForInput(debt.remaining)
          : '',
    );
    // Se recuerda la última elección del usuario.
    final prefs = await SharedPreferences.getInstance();
    var recordExpense = prefs.getBool(DebtExpense.prefKey) ?? true;
    if (!mounted) return;
    Future<void> pay(BuildContext context) async {
      final amount = CurrencyHelper.parseAmount(amountController.text) ?? 0;
      if (amount <= 0) return;
      await prefs.setBool(DebtExpense.prefKey, recordExpense);
      if (!context.mounted) return;
      final success = await AppGuard.runWithFeedback(
        context,
        () => _controller.makePayment(
          debt.id!,
          amount,
          recordExpenseFor: recordExpense ? debt : null,
        ),
      );
      if (!context.mounted) return;
      if (success) {
        Navigator.pop(context);
        _loadDebts();
      }
    }

    AppSheet.show<void>(
      context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = context.read<AppLocaleController>();
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSheetTitle(
                  l10n.text('payment_amount_for', {'name': debt.nombre}),
                ),
                AppSectionTitle(
                  l10n.text('payment_amount_hint'),
                  spaceAbove: false,
                ),
                GlassInput(
                  controller: amountController,
                  label: '',
                  hintText: '0.00',
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [CurrencyInputFormatter()],
                  prefix: Text(
                    '${CurrencyHelper.getSymbol(context)} ',
                    style: AppTextStyles.bodyMain,
                  ),
                  onSubmitted: () => pay(context),
                ),
                const SizedBox(height: AppSpacing.md),
                // Registrar el pago como gasto: así el balance refleja la
                // plata que salió. Apagalo si ya cargás el pago a mano.
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: recordExpense,
                  title: Text(
                    l10n.text('debt_record_expense'),
                    style: AppTextStyles.bodyMain,
                  ),
                  subtitle: Text(
                    l10n.text('debt_record_expense_hint', {
                      'category': DebtExpense.categoryFor(debt.nombre),
                    }),
                    style: AppTextStyles.bodySmall,
                  ),
                  onChanged: (v) => setModalState(() => recordExpense = v),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  onTap: () => pay(context),
                  color: AppColors.primaryPurple,
                  label: l10n.text('confirm_payment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddDebtFab(BuildContext context) {
    return AppRoundButton(icon: AppIcons.add, onTap: () => _showDebtForm());
  }

  Widget _buildTotalSummary(
    BuildContext context,
    AppLocaleController l10n,
    double total,
  ) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        borderRadius: AppRadius.xl,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "${l10n.text('total_debt_label')}: ",
                style: AppTextStyles.subLabel.copyWith(
                  color: AppColors.softText.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: CurrencyHelper.formatPrivate(total, context),
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDebtItem(
    BuildContext context,
    Debt debt, {
    bool isPriority = false,
  }) {
    final l10n = context.read<AppLocaleController>();
    final bool isPaid = debt.isPaid;
    final Color accent = isPaid
        ? AppColors.incomeGreen
        : (isPriority ? AppColors.primaryPurple : AppColors.textPrimary);
    final IconData icon = isPaid
        ? AppIcons.done
        : (isPriority && _selectedStrategy == 'avalanche'
              ? AppIcons.avalanche
              : (isPriority && _selectedStrategy == 'snowball'
                    ? AppIcons.snowball
                    : AppIcons.debts));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        border: isPaid
            ? Border.all(color: AppColors.incomeGreen.withValues(alpha: 0.3))
            : (isPriority
                  ? Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.4),
                      width: 1.5,
                    )
                  : null),
        child: Column(
          children: [
            AppListRow(
              framed: false,
              icon: icon,
              iconColor: accent,
              title: debt.nombre,
              titleTrailing: isPaid
                  ? _DebtBadge(
                      label: l10n.text('paid_label'),
                      color: AppColors.incomeGreen,
                      filled: true,
                    )
                  : (isPriority
                        ? _DebtBadge(
                            label: l10n.text('priority_label'),
                            color: AppColors.primaryPurple,
                          )
                        : null),
              extra: [
                const SizedBox(height: AppSpacing.sm),
                AppProgressBar(
                  value: debt.progress,
                  color: isPaid
                      ? AppColors.incomeGreen
                      : AppColors.primaryPurple,
                ),
                if (debt.diaCierre != null)
                  _debtDetail(
                    AppIcons.day,
                    l10n.text('cierre_dia') + _formatDateShort(debt.diaCierre),
                  ),
                if (debt.cuotasTotales != null)
                  _debtDetail(
                    AppIcons.installmentCount,
                    "${l10n.text('installments_label')}: ${debt.cuotasTotales}",
                  ),
              ],
              trailing: AppAmount.list(
                value: debt.remaining,
                label: isPaid ? l10n.text('paid_label') : null,
                color: isPaid ? AppColors.incomeGreen : AppColors.textPrimary,
              ),
              trailingCaption: Text(
                "${isPaid ? 100 : (debt.progress * 100).floor().clamp(0, 99)}%",
                style: AppTextStyles.rowSubtitle.copyWith(
                  color: isPaid ? AppColors.incomeGreen : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppActionButton(
                  icon: AppIcons.pay,
                  color: AppColors.incomeGreen,
                  onTap: () => _showPaymentModal(debt),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppActionButton(
                  icon: AppIcons.edit,
                  color: AppColors.primaryPurple,
                  onTap: () => _showDebtForm(debt: debt),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppActionButton(
                  icon: AppIcons.delete,
                  color: AppColors.expenseRed,
                  onTap: () => _confirmDeleteDebt(debt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Renglón chico de la tarjeta de deuda (cierre, cuotas).
  Widget _debtDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.small, color: AppColors.softTextDim),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.rowSubtitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDebt(Debt debt) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = context.watch<AppLocaleController>();
        return AlertDialog(
          title: Text(l10n.text('delete_debt_title')),
          content: Text(
            l10n
                .text('confirm_delete')
                .replaceFirst('movimiento', "'${debt.nombre}'"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.text('cancel')),
            ),
            TextButton(
              onPressed: () async {
                final success = await AppGuard.runWithFeedback(
                  context,
                  () => _controller.deleteDebt(debt.id!),
                );
                if (!context.mounted) return;
                if (success) {
                  Navigator.pop(context);
                  _loadDebts();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.expenseRed,
              ),
              child: Text(l10n.text('delete')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStrategySection(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.text('choose_strategy').toUpperCase(),
            style: AppTextStyles.subLabel.copyWith(
              letterSpacing: 1.2,
              color: AppColors.softText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildStrategyCard(
            title: l10n.text('avalanche_strategy'),
            icon: AppIcons.avalanche,
            color: AppColors.primaryPurple,
            isSelected: _selectedStrategy == 'avalanche',
            onTap: () => _selectStrategy('avalanche'),
          ),
          const SizedBox(height: 12),
          _buildStrategyCard(
            title: l10n.text('snowball_strategy'),
            icon: AppIcons.snowball,
            color: AppColors.primaryPurple,
            isSelected: _selectedStrategy == 'snowball',
            onTap: () => _selectStrategy('snowball'),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    AppColors.primaryPurple.withValues(alpha: 0.1),
                    AppColors.primaryPurple.withValues(alpha: 0.05),
                  ]
                : [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.02),
                  ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple.withValues(alpha: 0.12)
                    : AppColors.glassSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                      )
                    : const Icon(
                        AppIcons.next,
                        size: 20,
                        color: AppColors.softText,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta chica al lado del nombre de una deuda: "PAGADA" o "PRIORIDAD".
/// Solo existe en Deudas.
class _DebtBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _DebtBadge({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: filled ? AppColors.darkBackground : color,
        ),
      ),
    );
  }
}
