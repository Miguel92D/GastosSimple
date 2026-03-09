import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../controllers/budget_controller.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _controller = BudgetController.instance;

  final List<String> _categoriasGasto = [
    'Comida',
    'Transporte',
    'Ocio',
    'Salud',
    'Educación',
    'Otros',
  ];

  Map<String, double> _budgets = {};
  Map<String, double> _spent = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgets = await _controller.loadAllLimits(_categoriasGasto);
    final spent = await _controller.loadAllSpent(_categoriasGasto);

    if (mounted) {
      setState(() {
        _spent = spent;
        _budgets = budgets;
        _isLoading = false;
      });
    }
  }

  Future<void> _setBudget(String category) async {
    final controllerText = TextEditingController(
      text: _budgets[category] == 0 ? '' : _budgets[category].toString(),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(
              context,
            )!.budget_title(L10nHelper.getLocalizedCategory(context, category)),
          ),
          content: TextField(
            controller: controllerText,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.budget_example,
              prefixText: CurrencyHelper.getSymbol(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controllerText.text),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final amount = double.tryParse(result.replaceAll(',', '.'));
      if (amount != null) {
        await _controller.updateLimit(category, amount);
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            AppLocalizations.of(context)!.budgets,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categoriasGasto.length,
                itemBuilder: (context, index) {
                  final cat = _categoriasGasto[index];
                  final limit = _budgets[cat] ?? 0;
                  final spent = _spent[cat] ?? 0;

                  bool hasBudget = limit > 0;
                  bool exceeded = hasBudget && spent > limit;
                  double progress = hasBudget
                      ? (spent / limit).clamp(0.0, 1.0)
                      : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => _setBudget(cat),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    L10nHelper.getLocalizedCategory(
                                      context,
                                      cat,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (hasBudget)
                                  Flexible(
                                    child: Text(
                                      '${CurrencyHelper.format(spent, context)} / ${CurrencyHelper.format(limit, context)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: exceeded
                                            ? Colors.red
                                            : Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                if (!hasBudget)
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.not_set,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                            if (hasBudget) ...[
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  exceeded ? Colors.red : Colors.green,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
