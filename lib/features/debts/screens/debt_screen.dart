import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../../../core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_helper.dart';
import '../controllers/debt_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/flow/app_guard.dart';

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
    if (_selectedStrategy == 'avalanche') {
      _debts.sort((a, b) => (b.tasaInteres ?? 0).compareTo(a.tasaInteres ?? 0));
    } else if (_selectedStrategy == 'snowball') {
      _debts.sort((a, b) => a.remaining.compareTo(b.remaining));
    }
  }

  void _selectStrategy(String strategy) {
    setState(() {
      _selectedStrategy = strategy;
      _sortDebts();
    });
  }


  void _showDebtForm({Debt? debt}) {
    final nombreController = TextEditingController(text: debt?.nombre);
    final montoTotalController = TextEditingController(
      text: debt != null ? debt.montoTotal.toInt().toString() : '',
    );
    final pagoMinimoController = TextEditingController(
      text: debt != null ? debt.pagoMinimo.toInt().toString() : '',
    );
    final tasaInteresController = TextEditingController(
      text: debt?.tasaInteres != null ? debt!.tasaInteres!.toString() : '',
    );
    final fechaVencimientoController = TextEditingController(
      text: debt?.fechaVencimiento ?? '',
    );
    final diaCierreController = TextEditingController(
      text: debt?.diaCierre?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final innerL10n = context.read<AppLocaleController>();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1A172B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
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
                  _buildField(innerL10n.text('debt_name_label'), nombreController, icon: Icons.badge_rounded),
                  _buildField(innerL10n.text('total_amount'), montoTotalController, keyboard: TextInputType.number, icon: Icons.account_balance_wallet_rounded),
                  _buildField(innerL10n.text('min_payment'), pagoMinimoController, keyboard: TextInputType.number, icon: Icons.payment_rounded),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(innerL10n.text('interest_rate_optional'), tasaInteresController, keyboard: TextInputType.number, icon: Icons.percent_rounded),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          innerL10n.text('due_day_label'),
                          fechaVencimientoController,
                          keyboard: TextInputType.number,
                          icon: Icons.calendar_today_rounded,
                          textInputAction: TextInputAction.done,
                          onSubmitted: () => _saveDebt(
                            debt,
                            nombreController,
                            montoTotalController,
                            pagoMinimoController,
                            tasaInteresController,
                            fechaVencimientoController,
                            diaCierreController,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _saveDebt(
                      debt,
                      nombreController,
                      montoTotalController,
                      pagoMinimoController,
                      tasaInteresController,
                      fechaVencimientoController,
                      diaCierreController,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 5,
                      shadowColor: AppColors.primaryPurple.withValues(alpha: 0.5),
                    ),
                    child: Text(innerL10n.text('save_debt'), style: AppTextStyles.buttonLabel),
                  ),
                  const SizedBox(height: 20),
                ],
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
      montoTotal: double.tryParse(montoTotalController.text) ?? 0,
      pagoMinimo: double.tryParse(pagoMinimoController.text) ?? 0,
      tasaInteres: double.tryParse(tasaInteresController.text),
      fechaVencimiento: fechaVencimientoController.text,
      diaCierre: int.tryParse(diaCierreController.text),
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

  Widget _buildField(String label, TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
          style: AppTextStyles.bodyMain.copyWith(fontSize: 16),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            labelText: label,
            labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.softText.withValues(alpha: 0.5)),
            prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.primaryPurple.withValues(alpha: 0.6)) : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final totalRemaining = _debts.fold(0.0, (sum, d) => sum + d.remaining);

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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalSummary(context, totalRemaining),
                  const SizedBox(height: 32),
                  if (_debts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
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
                                Icons.account_balance_rounded,
                                size: 64,
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.text('no_debts_empty'),
                              style: AppTextStyles.titleLarge.copyWith(
                                fontSize: 18,
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
                                  borderRadius: BorderRadius.circular(16),
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
                    ..._debts.map((debt) => _buildDebtItem(context, debt)),
                  const SizedBox(height: 24),
                  _buildStrategySection(context),
                ],
              ),
            ),
    );
  }

  void _showPaymentModal(Debt debt) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: GlassCard(
              borderRadius: 30,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.read<AppLocaleController>().text('payment_amount_for', {'name': debt.nombre}),
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(context.read<AppLocaleController>().text('payment_amount_hint'), style: AppTextStyles.subLabel),
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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) async {
                          final amount = double.tryParse(amountController.text) ?? 0;
                          if (amount > 0) {
                            await _controller.makePayment(debt.id!, amount);
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
                          prefixText: CurrencyHelper.getSymbol(context) + ' ',
                          prefixStyle: AppTextStyles.bodyMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount > 0) {
                          final success = await AppGuard.runWithFeedback(
                            context,
                            () => _controller.makePayment(debt.id!, amount),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(context);
                            _loadDebts();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(context.read<AppLocaleController>().text('confirm_payment'), style: AppTextStyles.buttonLabel),
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
                Icons.add_rounded,
                color: AppColors.primaryPurple,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSummary(BuildContext context, double total) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        borderRadius: 20,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "DEUDA TOTAL: ",
                style: AppTextStyles.subLabel.copyWith(
                  color: AppColors.softText.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: CurrencyHelper.format(total, context),
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

  Widget _buildDebtItem(BuildContext context, Debt debt) {
    final bool isPaid = debt.progress >= 0.999;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        glowColor: isPaid ? AppColors.incomeGreen : null,
        border: isPaid ? Border.all(color: AppColors.incomeGreen.withValues(alpha: 0.4), width: 1.5) : null,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isPaid ? AppColors.incomeGreen.withValues(alpha: 0.15) : AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPaid ? AppColors.incomeGreen.withValues(alpha: 0.4) : AppColors.cardBorder,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : (debt.nombre.toLowerCase().contains('bbva')
                              ? Icons.account_balance_rounded
                              : Icons.credit_card_rounded),
                      color: isPaid ? AppColors.incomeGreen : AppColors.textPrimary,
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
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 18,
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
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.read<AppLocaleController>().text('paid_label'),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildCustomProgressBar(debt.progress, debt.nombre),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isPaid ? context.read<AppLocaleController>().text('paid_label') : CurrencyHelper.format(debt.remaining, context),
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                        color: isPaid ? AppColors.incomeGreen : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(debt.progress * 100).toInt()}%",
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
                  icon: Icons.payments_rounded,
                  color: AppColors.incomeGreen,
                  onTap: () => _showPaymentModal(debt),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: AppColors.primaryPurple,
                  onTap: () => _showDebtForm(debt: debt),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
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
          borderRadius: BorderRadius.circular(12),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.text('delete_debt_title'), style: AppTextStyles.cardTitle),
          content: Text(l10n.text('confirm_delete').replaceFirst('movimiento', "'${debt.nombre}'")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.text('cancel').toUpperCase(), style: const TextStyle(color: AppColors.softText)),
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
              child: Text(l10n.text('delete').toUpperCase(), style: const TextStyle(color: AppColors.expenseRed)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomProgressBar(double progress, String name) {
    final bool isPaid = progress >= 0.999;
    
    final color = isPaid 
        ? AppColors.incomeGreen 
        : (name.toLowerCase().contains('bbva')
            ? AppColors.orange
            : AppColors.primaryPurple);

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
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.text('choose_strategy'),
            style: AppTextStyles.subLabel.copyWith(
              letterSpacing: 1.2,
              color: AppColors.softText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildStrategyCard(
            title: l10n.text('avalanche_strategy'),
            icon: Icons.bolt_rounded,
            color: Colors.blueAccent,
            isSelected: _selectedStrategy == 'avalanche',
            onTap: () => _selectStrategy('avalanche'),
          ),
          const SizedBox(height: 12),
          _buildStrategyCard(
            title: l10n.text('snowball_strategy'),
            icon: Icons.ac_unit_rounded,
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1.5,
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
                  width: isSelected ? 1.5 : 1,
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
                    : const Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppColors.softText),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
