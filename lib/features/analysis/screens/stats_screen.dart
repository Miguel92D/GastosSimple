import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../services/pro_service.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final catGastos = _catGastos;
    double totalGastos = catGastos.values.fold(0, (sum, val) => sum + val);

    final List<Color> pieColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            AppLocalizations.of(context)!.history,
            style: TextStyle(
              color: ProService.instance.isPro
                  ? const Color(0xFFFFA000)
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.category_expenses,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (catGastos.isEmpty)
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_expenses_recorded,
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: catGastos.entries.map((e) {
                          final index = catGastos.keys.toList().indexOf(e.key);
                          final percentage = (e.value / totalGastos) * 100;
                          return PieChartSectionData(
                            value: e.value,
                            title: '${percentage.toStringAsFixed(0)}%',
                            color: pieColors[index % pieColors.length],
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Legend
                  ...catGastos.entries.map((e) {
                    final index = catGastos.keys.toList().indexOf(e.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: pieColors[index % pieColors.length],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    L10nHelper.getLocalizedCategory(
                                      context,
                                      e.key,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              CurrencyHelper.format(e.value, context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}
