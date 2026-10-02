import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/router/navigation_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/month_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/money.dart';
import '../../../services/stats_service.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/utils/transaction_filter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const List<Color> _chartColors = [
    AppColors.primaryPurple,
    Color(0xFFC084FC),
    Color(0xFF6366F1),
    AppColors.incomeGreen,
    Color(0xFF38BDF8),
    Color(0xFFFBBF24),
    AppColors.expenseRed,
    Color(0xFFFB7185),
  ];

  List<MapEntry<String, double>> _categories = [];
  List<MonthTotals> _trend = [];
  bool _isLoading = true;
  int _loadVersion = 0;
  DateTime _loadedMonth = MonthController.instance.selectedMonth;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(_loadData);
    MonthController.instance.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(_loadData);
    MonthController.instance.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    // El desglose corresponde al mes seleccionado, igual que el dashboard.
    final loadVersion = ++_loadVersion;
    final selectedMonth = MonthController.instance.selectedMonth;
    final List<Transaction> history =
        await TransactionController.getNormalHistory();
    final monthEnd = DateTime(selectedMonth.year, selectedMonth.month + 1);
    final monthItems = history
        .where((t) => !t.date.isBefore(selectedMonth) && t.date.isBefore(monthEnd))
        .toList();

    if (mounted && loadVersion == _loadVersion) {
      setState(() {
        _categories = StatsService.expensesByCategory(monthItems);
        _trend = StatsService.monthlyTrend(history, endMonth: selectedMonth);
        _loadedMonth = selectedMonth;
        _touchedIndex = null;
        _isLoading = false;
      });
    }
  }

  String _sliceName(ChartSlice slice) => slice.key == StatsService.othersKey
      ? context.read<AppLocaleController>().text('stats_others')
      : L10nHelper.getLocalizedCategory(context, slice.key);

  /// Abre Movimientos filtrado por esa(s) categoría(s), gastos y el mes.
  void _openMovements(List<String> categories) {
    HapticFeedback.lightImpact();
    NavigationService.navigate(
      '/movements',
      arguments: {
        'filter': TransactionFilter(
          type: TypeFilter.expense,
          categories: categories.toSet(),
          period: PeriodFilter.specificMonth,
          month: _loadedMonth,
        ),
      },
    );
  }

  String _money(double v) =>
      AppState.instance.hideBalance ? '••••••' : CurrencyHelper.format(v, context);

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('statistics'),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: AppState.instance,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                children: [
                  _buildMonthHeader(),
                  const SizedBox(height: 16),
                  _buildDonutCard(l10n),
                  const SizedBox(height: 24),
                  _buildTrendCard(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthHeader() {
    final monthController = MonthController.instance;
    final canGoNext = monthController.canGoNext();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () {
            HapticFeedback.selectionClick();
            monthController.goToPreviousMonth();
          },
        ),
        GestureDetector(
          onTap: monthController.isCurrentMonth()
              ? null
              : monthController.goToCurrentMonth,
          child: Text(
            L10nHelper.getLocalizedDateMonth(context, _loadedMonth),
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            color: canGoNext ? null : AppColors.softText.withValues(alpha: 0.2),
          ),
          onPressed: canGoNext
              ? () {
                  HapticFeedback.selectionClick();
                  monthController.goToNextMonth();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDonutCard(AppLocaleController l10n) {
    final total = _categories.fold(0.0, (s, e) => Money.round(s + e.value));
    final slices = StatsService.slices(_categories);
    final touched = (_touchedIndex != null && _touchedIndex! < slices.length)
        ? slices[_touchedIndex!]
        : null;

    return GlassCard(
      borderRadius: 30,
      glowColor: AppColors.primaryPurple.withValues(alpha: 0.08),
      child: Column(
        children: [
          Text(
            l10n.text('category_expenses'),
            style: AppTextStyles.titleLarge.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 24),
          if (_categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(l10n.text('no_expenses_recorded')),
            )
          else ...[
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 78,
                      startDegreeOffset: -90,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          if (event is! FlTapUpEvent) return;
                          final index =
                              response?.touchedSection?.touchedSectionIndex;
                          HapticFeedback.selectionClick();
                          setState(() {
                            _touchedIndex =
                                (index == null || index < 0 || index == _touchedIndex)
                                ? null
                                : index;
                          });
                        },
                      ),
                      sections: [
                        for (var i = 0; i < slices.length; i++)
                          PieChartSectionData(
                            value: slices[i].value,
                            color: _chartColors[i % _chartColors.length]
                                .withValues(
                                  alpha: _touchedIndex == null ||
                                          _touchedIndex == i
                                      ? 1
                                      : 0.35,
                                ),
                            radius: _touchedIndex == i ? 34 : 26,
                            showTitle: false,
                          ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 250),
                  ),
                  // Centro del anillo: total del mes o la porción tocada.
                  IgnorePointer(
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            touched == null
                                ? l10n.text('monthly_total').toUpperCase()
                                : _sliceName(touched).toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subLabel.copyWith(
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            child: Text(
                              _money(touched?.value ?? total),
                              style: AppTextStyles.balanceAmount.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.expenseRed,
                              ),
                            ),
                          ),
                          if (touched != null && total > 0)
                            Text(
                              AppState.instance.hideBalance
                                  ? '••%'
                                  : '${(touched.value / total * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: touched == null
                  ? Text(
                      l10n.text('stats_tap_hint'),
                      key: const ValueKey('hint'),
                      style: AppTextStyles.bodySmall,
                    )
                  : TextButton.icon(
                      key: ValueKey(touched.key),
                      onPressed: () => _openMovements(touched.categories),
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: Text(
                        l10n.text('stats_see_movements', {
                          'c': _sliceName(touched),
                        }),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < _categories.length; i++)
              _buildCategoryRow(
                _categories[i],
                total,
                _colorForCategory(_categories[i].key, slices),
              ),
          ],
        ],
      ),
    );
  }

  Color _colorForCategory(String category, List<ChartSlice> slices) {
    final index = slices.indexWhere((s) => s.categories.contains(category));
    return _chartColors[(index < 0 ? 0 : index) % _chartColors.length];
  }

  Widget _buildCategoryRow(
    MapEntry<String, double> e,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? e.value / total : 0.0;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openMovements([e.key]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    L10nHelper.getLocalizedCategory(context, e.key),
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _money(e.value),
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: Text(
                    AppState.instance.hideBalance
                        ? '••%'
                        : '${(percentage * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.softText.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.softText.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(AppLocaleController l10n) {
    final maxY = _trend.fold(
      0.0,
      (m, t) => [m, t.income, t.expense].reduce((a, b) => a > b ? a : b),
    );
    final withData = _trend.where((t) => t.income > 0 || t.expense > 0);
    final avgSaving = withData.isEmpty
        ? 0.0
        : withData.fold(0.0, (s, t) => s + t.saving) / withData.length;
    final monthFormat = DateFormat('MMM', l10n.locale);

    return GlassCard(
      borderRadius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.text('stats_trend_title'),
            style: AppTextStyles.titleLarge.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(AppColors.incomeGreen, l10n.text('income')),
              const SizedBox(width: 16),
              _legendDot(AppColors.expenseRed, l10n.text('expense')),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: maxY == 0
                ? Center(child: Text(l10n.text('no_movements_recorded')))
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.1,
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= _trend.length) {
                                return const SizedBox.shrink();
                              }
                              final isSelected = i == _trend.length - 1;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthFormat.format(_trend[i].month),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < _trend.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: _trend[i].income,
                                color: AppColors.incomeGreen,
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: _trend[i].expense,
                                color: AppColors.expenseRed,
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.text('stats_avg_saving', {'v': _money(avgSaving)}),
            style: AppTextStyles.bodySmall.copyWith(
              color: avgSaving >= 0
                  ? AppColors.incomeGreen
                  : AppColors.expenseRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
