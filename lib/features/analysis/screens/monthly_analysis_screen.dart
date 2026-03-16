import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';



class MonthlyAnalysisScreen extends StatefulWidget {
  const MonthlyAnalysisScreen({super.key});

  @override
  State<MonthlyAnalysisScreen> createState() => _MonthlyAnalysisScreenState();
}

class _MonthlyAnalysisScreenState extends State<MonthlyAnalysisScreen> {
  bool _isLoading = true;
  double _currentMonthIncome = 0;
  double _currentMonthExpense = 0;
  double _prevMonthExpense = 0;
  String _topSpendingDay = "";
  double _dailyAverage = 0;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final currentMonthData = await TransactionController.getTransactionsInMonth(month: now);
    
    final prevMonth = DateTime(now.year, now.month - 1);
    final prevMonthData = await TransactionController.getTransactionsInMonth(month: prevMonth);

    // Calculations
    double income = 0;
    double expense = 0;
    Map<int, double> dailySpending = {};
    Map<String, double> categories = {};

    for (var tx in currentMonthData) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else {
        expense += tx.amount;
        // Group by day
        int day = tx.date.day;
        dailySpending[day] = (dailySpending[day] ?? 0) + tx.amount;
        // Group by category
        categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
      }
    }

    double prevExpense = 0;
    for (var tx in prevMonthData) {
      if (tx.type == 'expense') {
        prevExpense += tx.amount;
      }
    }

    // Find top spending day
    int maxDay = 0;
    double maxAmount = 0;
    dailySpending.forEach((day, amt) {
      if (amt > maxAmount) {
        maxAmount = amt;
        maxDay = day;
      }
    });

    if (mounted) {
      setState(() {
        _currentMonthIncome = income;
        _currentMonthExpense = expense;
        _prevMonthExpense = prevExpense;
        _topSpendingDay = maxDay > 0 ? "$maxDay" : "-";
        _dailyAverage = now.day > 0 ? expense / now.day : 0;
        _isLoading = false;
      });

    }
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
                  _buildSummaryCard(l10n),
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

  Widget _buildSummaryCard(AppLocaleController l10n) {
    return GlassCard(
      glowColor: AppColors.primaryPurple.withValues(alpha: 0.1),
      child: Column(
        children: [
          Text(
            l10n.text('income_vs_expense'),
            style: AppTextStyles.subLabel,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat(
                l10n.text('income'),
                _currentMonthIncome,
                AppColors.incomeGreen,
              ),
              Container(width: 1, height: 40, color: AppColors.cardBorder),
              _buildSimpleStat(
                l10n.text('expense'),
                _currentMonthExpense,
                AppColors.expenseRed,
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
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(
          CurrencyHelper.format(amount, context),
          style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 18),
        ),
      ],
    );
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
                Text(l10n.text('vs_previous_month'), style: AppTextStyles.subLabel),
                Text(
                  improved 
                    ? l10n.text('spent_less_than_last_month') 
                    : l10n.text('spent_more_than_last_month'),
                  style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildSmallDetailCard(String label, String value, IconData icon, Color color) {
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
