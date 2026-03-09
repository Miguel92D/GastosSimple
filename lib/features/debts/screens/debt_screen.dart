import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/pro_service.dart';
import '../../../core/ui/pro_badge.dart';
import '../../../core/utils/currency_helper.dart';
import '../controllers/debt_controller.dart';

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
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  debt == null ? l10n.new_debt : l10n.edit_debt,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: l10n.debt_name_label),
                ),
                TextField(
                  controller: montoTotalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.total_amount),
                ),
                TextField(
                  controller: pagoMinimoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.min_payment),
                ),
                TextField(
                  controller: tasaInteresController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.interest_rate_optional,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.help_outline, size: 20),
                      onPressed: () => _showInfoDialog(
                        context,
                        l10n.interest_rate_title,
                        l10n.interest_rate_desc,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: diaCierreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.card_closing_label,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.help_outline, size: 20),
                      onPressed: () => _showInfoDialog(
                        context,
                        l10n.card_closing_title,
                        l10n.card_closing_desc,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: fechaVencimientoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.due_day_label,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.help_outline, size: 20),
                      onPressed: () => _showInfoDialog(
                        context,
                        l10n.due_date_title,
                        l10n.due_date_desc,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final newDebt = Debt(
                      id: debt?.id,
                      nombre: nombreController.text,
                      montoTotal:
                          double.tryParse(montoTotalController.text) ?? 0,
                      pagoMinimo:
                          double.tryParse(pagoMinimoController.text) ?? 0,
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
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPayForm(Debt debt) {
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.pay} ${debt.nombre}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.amount_to_pay),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                await _controller.makePayment(debt.id!, amount);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadDebts();
              }
            },
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
      appBar: AppBar(
        title: Flexible(
          child: Text(l10n.debts, overflow: TextOverflow.ellipsis),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (ProService.instance.isPro)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.debt_exit_plan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const ProBadge(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.extra_monthly_amount,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _extraPayment = double.tryParse(val) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getPlanTips(context),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _debts.length,
                      itemBuilder: (context, index) {
                        final debt = _debts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              debt.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              l10n.remaining_amount(
                                CurrencyHelper.format(debt.remaining, context),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    LinearProgressIndicator(
                                      value: debt.progress,
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.redAccent,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
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
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            l10n.vence_dia +
                                                debt.fechaVencimiento,
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        l10n.cierre_dia +
                                            debt.diaCierre.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        l10n.interest_annual(
                                          debt.tasaInteres.toString(),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      alignment: WrapAlignment.spaceEvenly,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _showPayForm(debt),
                                          icon: const Icon(Icons.payment),
                                          label: Text(l10n.pay),
                                        ),
                                        TextButton.icon(
                                          onPressed: () =>
                                              _showDebtForm(debt: debt),
                                          icon: const Icon(Icons.edit),
                                          label: Text(l10n.edit),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            await _controller.deleteDebt(
                                              debt.id!,
                                            );
                                            _loadDebts();
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          label: Text(
                                            l10n.delete,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDebtForm(),
        label: Text(
          l10n.new_debt,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
