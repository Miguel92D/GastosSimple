import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/state/month_controller.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../services/monthly_finance_service.dart';
import '../../transactions/controllers/transaction_controller.dart';

class MonthlyAnalysisScreen extends StatefulWidget {
  const MonthlyAnalysisScreen({super.key});

  @override
  State<MonthlyAnalysisScreen> createState() => _MonthlyAnalysisScreenState();
}

class _MonthlyAnalysisScreenState extends State<MonthlyAnalysisScreen> {
  static const double _minimumSwipeDistance = 48;
  static const double _minimumSwipeVelocity = 300;

  bool _isLoading = true;
  double _currentMonthIncome = 0;
  double _currentMonthExpense = 0;
  double _prevMonthExpense = 0;
  String _topSpendingDay = "";
  double _dailyAverage = 0;
  int _loadVersion = 0;
  DateTime _loadedMonth = MonthController.instance.selectedMonth;
  double _horizontalDragDistance = 0;
  int _cardExitDirection = 0;
  DateTime? _lastSummarySwipeAt;

  @override
  void initState() {
    super.initState();
    MonthController.instance.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    MonthController.instance.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadVersion = ++_loadVersion;
    final selectedMonth = MonthController.instance.selectedMonth;

    try {
      final currentMonthData =
          await TransactionController.getTransactionsInMonth(
            month: selectedMonth,
          );

      final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      final prevMonthData = await TransactionController.getTransactionsInMonth(
        month: prevMonth,
      );

      final analysis = MonthlyFinanceService.buildAnalysis(
        currentMonthTransactions: currentMonthData,
        previousMonthTransactions: prevMonthData,
        selectedMonth: selectedMonth,
      );

      if (mounted &&
          loadVersion == _loadVersion &&
          MonthController.isSameMonth(
            selectedMonth,
            MonthController.instance.selectedMonth,
          )) {
        setState(() {
          _currentMonthIncome = analysis.income;
          _currentMonthExpense = analysis.expenses;
          _prevMonthExpense = analysis.previousMonthExpenses;
          _topSpendingDay = analysis.topSpendingDay;
          _dailyAverage = analysis.dailyAverage;
          _loadedMonth = selectedMonth;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading monthly analysis: $e');
      if (mounted && loadVersion == _loadVersion) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSummaryDragStart(DragStartDetails details) {
    _horizontalDragDistance = 0;
  }

  void _handleSummaryDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.delta.dx;
  }

  void _handleSummarySwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final distance = _horizontalDragDistance;
    _horizontalDragDistance = 0;

    if (distance.abs() < _minimumSwipeDistance &&
        velocity.abs() < _minimumSwipeVelocity) {
      return;
    }

    _lastSummarySwipeAt = DateTime.now();

    final monthController = MonthController.instance;
    final swipeToLeft =
        distance < -_minimumSwipeDistance ||
        (distance.abs() < _minimumSwipeDistance && velocity < 0);
    final swipeToRight =
        distance > _minimumSwipeDistance ||
        (distance.abs() < _minimumSwipeDistance && velocity > 0);

    if (swipeToRight) {
      _cardExitDirection = 1;
      monthController.goToPreviousMonth();
    } else if (swipeToLeft && monthController.canGoNext()) {
      _cardExitDirection = -1;
      monthController.goToNextMonth();
    }
  }

  void _goToCurrentMonthFromSummaryCard() {
    final lastSwipeAt = _lastSummarySwipeAt;
    if (lastSwipeAt != null &&
        DateTime.now().difference(lastSwipeAt) <
            const Duration(milliseconds: 250)) {
      return;
    }

    final monthController = MonthController.instance;
    if (monthController.isCurrentMonth()) return;

    _cardExitDirection = -1;
    monthController.goToCurrentMonth();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('monthly_analysis_title'),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSwipeableSummaryCard(l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildComparisonSection(l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDetailedStats(l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTipsSection(l10n),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildSwipeableSummaryCard(AppLocaleController l10n) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _goToCurrentMonthFromSummaryCard,
      onHorizontalDragStart: _handleSummaryDragStart,
      onHorizontalDragUpdate: _handleSummaryDragUpdate,
      onHorizontalDragEnd: _handleSummarySwipe,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          final exitDirection = _cardExitDirection == 0
              ? 1
              : _cardExitDirection;
          final isIncoming = child.key == ValueKey(_monthKey(_loadedMonth));
          final beginOffset = isIncoming
              ? Offset((-exitDirection).toDouble(), 0)
              : Offset(exitDirection.toDouble(), 0);

          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _buildSummaryCard(l10n, key: ValueKey(_monthKey(_loadedMonth))),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocaleController l10n, {required Key key}) {
    return GlassCard(
      key: key,
      glowColor: AppColors.primaryPurple.withValues(alpha: 0.1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Column(
              children: [
                Text(
                  l10n.text('income_vs_expense'),
                  style: AppTextStyles.subLabel,
                ),
                const SizedBox(height: 4),
                Text(
                  L10nHelper.getLocalizedDateMonth(context, _loadedMonth),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softText.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSimpleStat(
                  l10n.text('income'),
                  _currentMonthIncome,
                  AppColors.incomeGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 1,
                height: 40,
                color: AppColors.cardBorder,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSimpleStat(
                  l10n.text('expense'),
                  _currentMonthExpense,
                  AppColors.expenseRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyHelper.format(amount, context),
              maxLines: 1,
              style: AppTextStyles.cardTitle.copyWith(
                color: color,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _monthKey(DateTime month) {
    return '${month.year}-${month.month}';
  }

  Widget _buildComparisonSection(AppLocaleController l10n) {
    double diff = _currentMonthExpense - _prevMonthExpense;
    bool improved = diff <= 0;

    return GlassCard(
      child: Row(
        children: [
          Icon(
            improved ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            color: improved ? AppColors.incomeGreen : AppColors.expenseRed,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('vs_previous_month'),
                  style: AppTextStyles.subLabel,
                ),
                Text(
                  improved
                      ? l10n.text('spent_less_than_last_month')
                      : l10n.text('spent_more_than_last_month'),
                  style: AppTextStyles.bodyMain.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyHelper.format(diff.abs(), context),
            style: AppTextStyles.bodyMain.copyWith(
              color: improved ? AppColors.incomeGreen : AppColors.expenseRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(AppLocaleController l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallDetailCard(
            l10n.text('top_spending_day'),
            _topSpendingDay,
            Icons.calendar_today_rounded,
            AppColors.primaryPurple,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildSmallDetailCard(
            l10n.text('daily_average'),
            CurrencyHelper.format(_dailyAverage, context),
            Icons.speed_rounded,
            AppColors.incomeGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDetailCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTextStyles.subLabel.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(AppLocaleController l10n) {
    return GlassCard(
      glowColor: AppColors.incomeGreen.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _generateInsight(l10n),
              style: AppTextStyles.bodyMain.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateInsight(AppLocaleController l10n) {
    if (_currentMonthExpense > _currentMonthIncome) {
      return l10n.text('insight_negative_balance');
    } else if (_dailyAverage > 50) {
      return l10n.text('insight_high_daily_avg');
    } else {
      return l10n.text('insight_positive_balance');
    }
  }
}
