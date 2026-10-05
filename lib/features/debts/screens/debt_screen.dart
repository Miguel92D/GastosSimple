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
      text: debt != null ? CurrencyHelper.formatAmountForInput(debt.montoTotal) : '',
    );
    final pagoMinimoController = TextEditingController(
      text: debt != null ? CurrencyHelper.formatAmountForInput(debt.pagoMinimo) : '',
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        final innerL10n = context.read<AppLocaleController>();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  32, // Margen generoso
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        debt == null ? innerL10n.text('new_debt') : innerL10n.text('edit_debt'),
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildField(innerL10n.text('debt_name_label'), nombreController, icon: AppIcons.name),
                      _buildField(innerL10n.text('total_amount'), montoTotalController, keyboard: const TextInputType.numberWithOptions(decimal: true), icon: AppIcons.wallet, inputFormatters: [CurrencyInputFormatter()]),
                      _buildField(innerL10n.text('min_payment'), pagoMinimoController, keyboard: const TextInputType.numberWithOptions(decimal: true), icon: AppIcons.pay, inputFormatters: [CurrencyInputFormatter()]),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(innerL10n.text('interest_rate_optional'), tasaInteresController, keyboard: const TextInputType.numberWithOptions(decimal: true), icon: AppIcons.percent, fontSize: 14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              innerL10n.text('due_day_label'),
                              fechaVencimientoController,
                              keyboard: TextInputType.none,
                              icon: AppIcons.day,
                              readOnly: true,
                              onTap: () => _selectDate(context, fechaVencimientoController),
                              fontSize: 14,
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              innerL10n.text('card_closing_label'),
                              diaCierreController,
                              keyboard: TextInputType.none,
                              icon: AppIcons.day,
                              textInputAction: TextInputAction.done,
                              readOnly: true,
                              onTap: () => _selectDate(context, diaCierreController),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 32), // Mayor espacio para que el glow no se corte
                    ],
                  ),
                ),
              ),
            ),
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
        SnackBar(content: Text(context.read<AppLocaleController>().text('complete_name_and_amount'))),
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
      diaCierre: diaCierreController.text.isEmpty ? null : diaCierreController.text,
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
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
      controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/$yearShort";
    }
  }

  Widget _buildField(String label, TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
    VoidCallback? onTap,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
          onTap: onTap,
          readOnly: readOnly,
          style: AppTextStyles.bodyMain.copyWith(fontSize: fontSize),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            labelText: label,
            labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.softText.withValues(alpha: 0.5)),
            prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.primaryPurple.withValues(alpha: 0.6)) : null,
            prefixIconConstraints: icon != null ? const BoxConstraints(minWidth: 40, minHeight: 40) : null,
          ),
        ),
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
              child: CircularProgressIndicator(
                color: AppColors.primaryPurple,
              ),
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                AppIcons.debts,
                                size: 64,
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.text('no_debts_empty'),
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.textPrimary.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.text('no_debts_subtitle'),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.softText.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => _showDebtForm(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  l10n.text('add_first_debt'),
                                  style: AppTextStyles.buttonLabel.copyWith(color: AppColors.primaryPurple, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._debts.map((debt) {
                      final isPriority = _selectedStrategy != 'none' && debt == priorityDebt;
                      return _buildDebtItem(context, debt, isPriority: isPriority);
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
      text: !debt.isPaid ? CurrencyHelper.formatAmountForInput(debt.remaining) : '',
    );
    // Se recuerda la última elección del usuario.
    final prefs = await SharedPreferences.getInstance();
    var recordExpense = prefs.getBool(DebtExpense.prefKey) ?? true;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                32, // Margen generoso inferior para ergonomía
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    context.read<AppLocaleController>().text('payment_amount_for', {'name': debt.nombre}),
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(context.read<AppLocaleController>().text('payment_amount_hint').toUpperCase(), style: AppTextStyles.subLabel),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CurrencyInputFormatter()],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) async {
                        final amount = CurrencyHelper.parseAmount(amountController.text) ?? 0;
                        if (amount > 0) {
                          await prefs.setBool(DebtExpense.prefKey, recordExpense);
                          await _controller.makePayment(
                            debt.id!,
                            amount,
                            recordExpenseFor: recordExpense ? debt : null,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadDebts();
                        }
                      },
                      autofocus: true,
                      style: AppTextStyles.bodyMain,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        prefixText: '${CurrencyHelper.getSymbol(context)} ',
                        prefixStyle: AppTextStyles.bodyMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Registrar el pago como gasto: así el balance refleja la
                  // plata que salió. Apagalo si ya cargás el pago a mano.
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: recordExpense,
                    activeThumbColor: AppColors.primaryPurple,
                    title: Text(
                      context.read<AppLocaleController>().text('debt_record_expense'),
                      style: AppTextStyles.bodyMain,
                    ),
                    subtitle: Text(
                      context.read<AppLocaleController>().text(
                        'debt_record_expense_hint',
                        {'category': DebtExpense.categoryFor(debt.nombre)},
                      ),
                      style: AppTextStyles.bodySmall,
                    ),
                    onChanged: (v) => setModalState(() => recordExpense = v),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    onTap: () async {
                      final amount = CurrencyHelper.parseAmount(amountController.text) ?? 0;
                      if (amount > 0) {
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
                    },
                    color: AppColors.primaryPurple,
                    label: context.read<AppLocaleController>().text('confirm_payment'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildAddDebtFab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0), // Alineado con el menú
      child: GlassCard(
        width: 56,
        height: 56,
        borderRadius: 18,
        padding: EdgeInsets.zero,
        glowColor: AppColors.primaryPurple.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4), width: 2.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDebtForm(),
            borderRadius: BorderRadius.circular(18),
            child: const Center(
              child: Icon(
                AppIcons.add,
                color: AppColors.primaryPurple,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSummary(BuildContext context, AppLocaleController l10n, double total) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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

  Widget _buildDebtItem(BuildContext context, Debt debt, {bool isPriority = false}) {
    final bool isPaid = debt.isPaid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: AppRadius.lg,
        border: isPaid
            ? Border.all(color: AppColors.incomeGreen.withValues(alpha: 0.3), width: 1.0)
            : (isPriority ? Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4), width: 1.5) : null),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppColors.incomeGreen.withValues(alpha: 0.15)
                        : (isPriority ? AppColors.primaryPurple.withValues(alpha: 0.15) : AppColors.glassSurface),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isPaid
                          ? AppColors.incomeGreen.withValues(alpha: 0.4)
                          : (isPriority ? AppColors.primaryPurple.withValues(alpha: 0.5) : AppColors.cardBorder),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isPaid
                          ? AppIcons.done
                          : (isPriority && _selectedStrategy == 'avalanche'
                              ? AppIcons.avalanche
                              : (isPriority && _selectedStrategy == 'snowball'
                                  ? AppIcons.snowball
                                  : AppIcons.debts)),
                      color: isPaid ? AppColors.incomeGreen : (isPriority ? AppColors.primaryPurple : AppColors.textPrimary),
                      size: isPaid ? 24 : 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              debt.nombre,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isPaid ? AppColors.incomeGreen : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (isPaid) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.incomeGreen,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                context.read<AppLocaleController>().text('paid_label'),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.darkBackground,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ] else if (isPriority) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedStrategy == 'avalanche' ? AppIcons.avalanche : AppIcons.snowball,
                                    color: AppColors.primaryPurple,
                                    size: 10
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.read<AppLocaleController>().text('priority_label'), // Defaults to "Priority" in unknown locales
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryPurple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildCustomProgressBar(debt.progress, isPaid: isPaid),
                      if (debt.diaCierre != null || debt.cuotasTotales != null) ...[
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (debt.diaCierre != null)
                              Row(
                                children: [
                                  const Icon(AppIcons.day, size: 12, color: AppColors.softText),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      context.read<AppLocaleController>().text('cierre_dia') + _formatDateShort(debt.diaCierre),
                                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.softText),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (debt.cuotasTotales != null)
                              Padding(
                                padding: EdgeInsets.only(top: debt.diaCierre != null ? 4.0 : 0.0),
                                child: Row(
                                  children: [
                                    const Icon(AppIcons.installmentCount, size: 12, color: AppColors.softText),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${context.read<AppLocaleController>().text('installments_label')}: ${debt.cuotasTotales}",
                                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.softText),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isPaid ? context.read<AppLocaleController>().text('paid_label') : CurrencyHelper.formatPrivate(debt.remaining, context),
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                        color: isPaid ? AppColors.incomeGreen : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${isPaid ? 100 : (debt.progress * 100).floor().clamp(0, 99)}%",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isPaid ? AppColors.incomeGreen.withValues(alpha: 0.7) : AppColors.softText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: AppIcons.pay,
                  color: AppColors.incomeGreen,
                  onTap: () => _showPaymentModal(debt),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: AppIcons.edit,
                  color: AppColors.primaryPurple,
                  onTap: () => _showDebtForm(debt: debt),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Center(
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  void _confirmDeleteDebt(Debt debt) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = context.watch<AppLocaleController>();
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text(l10n.text('delete_debt_title'), style: AppTextStyles.cardTitle),
          content: Text(l10n.text('confirm_delete').replaceFirst('movimiento', "'${debt.nombre}'")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.text('cancel').toUpperCase(), style: AppTextStyles.buttonLabel.copyWith(color: AppColors.softText)),
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
              child: Text(l10n.text('delete').toUpperCase(), style: AppTextStyles.buttonLabel.copyWith(color: AppColors.expenseRed)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomProgressBar(double progress, {required bool isPaid}) {
    
    final color = isPaid 
        ? AppColors.incomeGreen 
        : AppColors.primaryPurple;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
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
            color: isSelected ? AppColors.primaryPurple : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    AppColors.primaryPurple.withValues(alpha: 0.1),
                    AppColors.primaryPurple.withValues(alpha: 0.05)
                  ]
                : [color.withValues(alpha: 0.15), color.withValues(alpha: 0.02)],
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
                  color: isSelected ? AppColors.primaryPurple : AppColors.cardBorder,
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
                    : const Icon(AppIcons.next,
                        size: 20, color: AppColors.softText),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
