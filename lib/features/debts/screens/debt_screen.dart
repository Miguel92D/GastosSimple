import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/pro_service.dart';
import '../../../core/ui/pro_badge.dart';
import '../../../core/utils/currency_helper.dart';
import '../controllers/debt_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final _controller = DebtController.instance;
  List<Debt> _debts = [];
  bool _isLoading = true;
  double _extraPayment = 0;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final debts = await _controller.loadDebts();
    if (mounted) {
      setState(() {
        _debts = debts;
        _isLoading = false;
      });
    }
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: AppTextStyles.cardTitle),
        content: Text(content, style: AppTextStyles.bodyMain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: AppTextStyles.bodyMain.copyWith(
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDebtForm({Debt? debt}) {
    final nombreController = TextEditingController(text: debt?.nombre);
    final montoTotalController = TextEditingController(
      text: debt?.montoTotal.toString(),
    );
    final pagoMinimoController = TextEditingController(
      text: debt?.pagoMinimo.toString(),
    );
    final tasaInteresController = TextEditingController(
      text: debt?.tasaInteres?.toString() ?? '',
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
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                debt == null ? l10n.new_debt : l10n.edit_debt,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildField(l10n.debt_name_label, nombreController),
              _buildField(
                l10n.total_amount,
                montoTotalController,
                keyboard: TextInputType.number,
              ),
              _buildField(
                l10n.min_payment,
                pagoMinimoController,
                keyboard: TextInputType.number,
              ),
              _buildField(
                l10n.interest_rate_optional,
                tasaInteresController,
                keyboard: TextInputType.number,
                helpTitle: l10n.interest_rate_title,
                helpDesc: l10n.interest_rate_desc,
                context: context,
              ),
              _buildField(
                l10n.card_closing_label,
                diaCierreController,
                keyboard: TextInputType.number,
                helpTitle: l10n.card_closing_title,
                helpDesc: l10n.card_closing_desc,
                context: context,
              ),
              _buildField(
                l10n.due_day_label,
                fechaVencimientoController,
                keyboard: TextInputType.number,
                helpTitle: l10n.due_date_title,
                helpDesc: l10n.due_date_desc,
                context: context,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
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

                  if (newDebt.diaCierre != null &&
                      (newDebt.diaCierre! < 1 || newDebt.diaCierre! > 31)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.closing_day_error,
                        ),
                      ),
                    );
                    return;
                  }

                  await _controller.saveDebt(newDebt);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadDebts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l10n.save, style: AppTextStyles.buttonLabel),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    String? helpTitle,
    String? helpDesc,
    BuildContext? context,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: AppTextStyles.bodyMain,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMain.copyWith(color: AppColors.textMuted),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryPurple),
        ),
        suffixIcon: helpTitle != null
            ? IconButton(
                icon: const Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: AppColors.softText,
                ),
                onPressed: () =>
                    _showInfoDialog(context!, helpTitle, helpDesc!),
              )
            : null,
      ),
    );
  }

  void _showPayForm(Debt debt) {
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '${l10n.pay} ${debt.nombre}',
          style: AppTextStyles.cardTitle,
        ),
        content: TextField(
          controller: amountController,
          autofocus: true,
          style: AppTextStyles.bodyMain,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.amount_to_pay,
            labelStyle: AppTextStyles.bodyMain.copyWith(
              color: AppColors.textMuted,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryPurple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                await _controller.makePayment(debt.id!, amount);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadDebts();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.pay),
          ),
        ],
      ),
    );
  }

  String _getPlanTips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_debts.isEmpty) return l10n.no_debts_recorded;

    List<String> tips = [];
    final debtWithMaxInterest = _debts
        .where((d) => d.tasaInteres != null)
        .toList();
    if (debtWithMaxInterest.isNotEmpty) {
      debtWithMaxInterest.sort(
        (a, b) => b.tasaInteres!.compareTo(a.tasaInteres!),
      );
      final d = debtWithMaxInterest.first;
      tips.add(l10n.priority_tip(d.nombre, d.tasaInteres!.toStringAsFixed(1)));
      if (_extraPayment > 0) {
        final totalPayment = d.pagoMinimo + _extraPayment;
        final months = (d.remaining / totalPayment).ceil();
        tips.add(
          l10n.extra_payment_tip(
            CurrencyHelper.format(_extraPayment, context),
            d.nombre,
            months,
          ),
        );
      }
    }
    final sortedByBalance = List<Debt>.from(_debts)
      ..sort((a, b) => a.remaining.compareTo(b.remaining));
    tips.add(l10n.snowball_method(sortedByBalance.first.nombre));
    return tips.join("\n\n");
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(l10n.debts),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (ProService.instance.isPro)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GlassCard(
                        borderRadius: 30,
                        glowColor: AppColors.primaryPurple.withOpacity(0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.debt_exit_plan,
                                    style: AppTextStyles.cardTitle,
                                  ),
                                ),
                                const ProBadge(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              keyboardType: TextInputType.number,
                              style: AppTextStyles.bodyMain,
                              decoration: InputDecoration(
                                labelText: l10n.extra_monthly_amount,
                                labelStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                isDense: true,
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _extraPayment = double.tryParse(val) ?? 0;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getPlanTips(context),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.softText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ..._debts.map(
                    (debt) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        borderRadius: 30,
                        padding: EdgeInsets.zero,
                        glowColor: AppColors.expenseRed.withOpacity(0.05),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(
                              debt.nombre,
                              style: AppTextStyles.cardTitle,
                            ),
                            subtitle: Text(
                              l10n.remaining_amount(
                                CurrencyHelper.format(debt.remaining, context),
                              ),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.softText,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: debt.progress,
                                        backgroundColor: AppColors.softText
                                            .withOpacity(0.08),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.expenseRed,
                                            ),
                                        minHeight: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l10n.min_pay_amount(
                                              CurrencyHelper.format(
                                                debt.pagoMinimo,
                                                context,
                                              ),
                                            ),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.softText,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '${l10n.vence_dia}${debt.fechaVencimiento}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.softText,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${l10n.cierre_dia}${debt.diaCierre}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.softText,
                                      ),
                                    ),
                                    if (debt.tasaInteres != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          l10n.interest_annual(
                                            debt.tasaInteres.toString(),
                                          ),
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.softText,
                                              ),
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      alignment: WrapAlignment.spaceEvenly,
                                      spacing: 8,
                                      children: [
                                        _buildActionButton(
                                          Icons.payment_rounded,
                                          l10n.pay,
                                          AppColors.incomeGreen,
                                          () => _showPayForm(debt),
                                        ),
                                        _buildActionButton(
                                          Icons.edit_rounded,
                                          l10n.edit,
                                          AppColors.softText,
                                          () => _showDebtForm(debt: debt),
                                        ),
                                        _buildActionButton(
                                          Icons.delete_rounded,
                                          l10n.delete,
                                          AppColors.expenseRed,
                                          () async {
                                            await _controller.deleteDebt(
                                              debt.id!,
                                            );
                                            _loadDebts();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDebtForm(),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
