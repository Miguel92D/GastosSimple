import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../controllers/budget_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

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
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            AppLocalizations.of(
              context,
            )!.budget_title(L10nHelper.getLocalizedCategory(context, category)),
            style: AppTextStyles.cardTitle,
          ),
          content: TextField(
            controller: controllerText,
            style: AppTextStyles.bodyMain,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.pop(context, value),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.budget_example,
              hintStyle: AppTextStyles.bodyMain.copyWith(
                color: AppColors.textMuted,
              ),
              prefixText: CurrencyHelper.getSymbol(context),
              prefixStyle: AppTextStyles.bodyMain.copyWith(
                color: AppColors.primaryPurple,
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
                AppLocalizations.of(context)!.cancel,
                style: AppTextStyles.bodyMain.copyWith(
                  color: AppColors.softText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controllerText.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
    return AppScaffold(
      title: AppLocalizations.of(context)!.budgets,
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: true,
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, child) {
          return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          borderRadius: 30,
                          glowColor:
                              (exceeded
                                      ? AppColors.expenseRed
                                      : AppColors.primaryPurple)
                                  .withOpacity(0.05),
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            onTap: () => _setBudget(cat),
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          L10nHelper.getLocalizedCategory(
                                            context,
                                            cat,
                                          ),
                                          style: AppTextStyles.cardTitle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (hasBudget)
                                        Flexible(
                                          child: Text(
                                            AppState.instance.hideBalance
                                                ? "•••••• / ••••••"
                                                : '${CurrencyHelper.format(spent, context)} / ${CurrencyHelper.format(limit, context)}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: exceeded
                                                      ? AppColors.expenseRed
                                                      : AppColors.softText,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      if (!hasBudget)
                                        Flexible(
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.not_set,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.textMuted,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (hasBudget) ...[
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: AppColors.softText
                                            .withOpacity(0.08),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              exceeded
                                                  ? AppColors.expenseRed
                                                  : AppColors.incomeGreen,
                                            ),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
        },
      ),
    );
  }
}
