import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';

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
      AppColors.primaryPurple,
      const Color(0xFFC084FC),
      const Color(0xFF6366F1),
      AppColors.incomeGreen,
      const Color(0xFF38BDF8),
      const Color(0xFFFBBF24),
      AppColors.expenseRed,
      const Color(0xFFFB7185),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
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
                  borderRadius: 30,
                  glowColor: AppColors.primaryPurple.withOpacity(0.08),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.category_expenses,
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 48),
                      if (catGastos.isEmpty)
                        Text(AppLocalizations.of(context)!.no_expenses_recorded)
                      else ...[
                        SizedBox(
                          height: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("TOTAL", style: AppTextStyles.subLabel),
                                  Text(
                                    CurrencyHelper.format(totalGastos, context),
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 6,
                                  centerSpaceRadius: 65,
                                  sections: catGastos.entries.map((e) {
                                    final index = catGastos.keys
                                        .toList()
                                        .indexOf(e.key);
                                    final percentage =
                                        (e.value / totalGastos) * 100;
                                    return PieChartSectionData(
                                      value: e.value,
                                      title: '',
                                      color:
                                          chartColors[index %
                                              chartColors.length],
                                      radius: 20,
                                      badgeWidget: _Badge(
                                        '${percentage.toStringAsFixed(0)}%',
                                        size: 40,
                                        borderColor:
                                            chartColors[index %
                                                chartColors.length],
                                      ),
                                      badgePositionPercentageOffset: .98,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 56),
                        ...catGastos.entries.map((e) {
                          final index = catGastos.keys.toList().indexOf(e.key);
                          final percentage = e.value / totalGastos;
                          final color = chartColors[index % chartColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: color.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.layers_rounded,
                                              size: 16,
                                              color: color,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            L10nHelper.getLocalizedCategory(
                                              context,
                                              e.key,
                                            ),
                                            style: AppTextStyles.cardTitle
                                                .copyWith(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyHelper.format(
                                            e.value,
                                            context,
                                          ),
                                          style: AppTextStyles.cardTitle
                                              .copyWith(fontSize: 16),
                                        ),
                                        Text(
                                          '${(percentage * 100).toStringAsFixed(1)}%',
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
                                    backgroundColor: AppColors.softText
                                        .withOpacity(0.05),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(this.text, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: size * .2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
