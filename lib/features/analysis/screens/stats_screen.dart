import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/design/app_colors.dart';

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final catGastos = _catGastos;
    double totalGastos = catGastos.values.fold(0, (sum, val) => sum + val);

    final List<Color> chartColors = [
      AppColors.primaryStart,
      AppColors.primaryEnd,
      const Color(0xFF4ADE80),
      const Color(0xFFF87171),
      const Color(0xFFFBBF24),
      const Color(0xFF2DD4BF),
      const Color(0xFFFB7185),
      const Color(0xFFA78BFA),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  glowColor: AppColors.primaryStart,
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.category_expenses,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (catGastos.isEmpty)
                        Text(AppLocalizations.of(context)!.no_expenses_recorded)
                      else ...[
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: catGastos.entries.map((e) {
                                final index = catGastos.keys.toList().indexOf(
                                  e.key,
                                );
                                final percentage =
                                    (e.value / totalGastos) * 100;
                                return PieChartSectionData(
                                  value: e.value,
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  color:
                                      chartColors[index % chartColors.length],
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ...catGastos.entries.map((e) {
                          final index = catGastos.keys.toList().indexOf(e.key);
                          final percentage = e.value / totalGastos;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color:
                                                chartColors[index %
                                                    chartColors.length],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          L10nHelper.getLocalizedCategory(
                                            context,
                                            e.key,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      CurrencyHelper.format(e.value, context),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.05,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      chartColors[index % chartColors.length],
                                    ),
                                    minHeight: 6,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
