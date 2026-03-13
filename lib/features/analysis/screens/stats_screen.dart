import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, double> _catGastos = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final catGastos = await TransactionController.getExpensesByCategory();

    if (mounted) {
      setState(() {
        _catGastos = catGastos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> chartColors = [
      AppColors.primaryPurple,
      const Color(0xFFC084FC),
      const Color(0xFF6366F1),
      AppColors.incomeGreen,
      const Color(0xFF38BDF8),
      const Color(0xFFFBBF24),
      AppColors.expenseRed,
      const Color(0xFFFB7185),
    ];

    return AppScaffold(
      title: context.watch<AppLocaleController>().text('history'),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: AppState.instance,
              builder: (context, child) {
                final catGastos = _catGastos;
                double totalGastos = catGastos.values.fold(0, (sum, val) => sum + val);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassCard(
                        borderRadius: 30,
                        glowColor: AppColors.primaryPurple.withValues(alpha: 0.08),
                        child: Column(
                          children: [
                            Text(
                              context.watch<AppLocaleController>().text('category_expenses'),
                              style: AppTextStyles.titleLarge.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 32),
                            if (catGastos.isEmpty)
                              Text(context.watch<AppLocaleController>().text('no_expenses_recorded'))
                            else ...[
                              Column(
                                children: [
                                  Text(
                                    context.watch<AppLocaleController>().text('monthly_total').toUpperCase(),
                                    style: AppTextStyles.subLabel.copyWith(
                                      color: AppColors.softText.withValues(alpha: 0.5),
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppState.instance.hideBalance
                                        ? "••••••"
                                        : CurrencyHelper.format(totalGastos, context),
                                    style: AppTextStyles.balanceAmount.copyWith(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: totalGastos > 0 ? AppColors.expenseRed : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 48),
                              ...catGastos.entries.map((e) {
                                final index = catGastos.keys.toList().indexOf(e.key);
                                final percentage = totalGastos > 0 ? e.value / totalGastos : 0.0;
                                final color = chartColors[index % chartColors.length];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 32,
                                                  width: 32,
                                                  decoration: BoxDecoration(
                                                    color: color.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    L10nHelper.getLocalizedCategory(context, e.key),
                                                    style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                AppState.instance.hideBalance
                                                    ? "••••••"
                                                    : CurrencyHelper.format(e.value, context),
                                                style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                                              ),
                                              Text(
                                                AppState.instance.hideBalance
                                                    ? "••%"
                                                    : '${(percentage * 100).toStringAsFixed(1)}%',
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          backgroundColor: AppColors.softText.withValues(alpha: 0.05),
                                          valueColor: AlwaysStoppedAnimation<Color>(color),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Espacio para el FAB flotante
                    ],
                  ),
                );
              },
            ),
    );
  }
}
