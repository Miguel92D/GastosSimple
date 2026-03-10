import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/state/app_state.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  bool _isLoading = true;
  double _currentIncome = 0;
  double _currentExpense = 0;
  double _predictedExpense = 0;
  double _predictedBalance = 0;
  int _daysPassed = 0;
  int _daysInMonth = 0;

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(_calculatePrediction);
    _calculatePrediction();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(_calculatePrediction);
    super.dispose();
  }

  Future<void> _calculatePrediction() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    _daysInMonth = nextMonth.difference(monthStart).inDays;
    _daysPassed = now.day;

    final transactions = await TransactionController.getTransactionsInMonth(
      month: now,
    );

    final income = transactions
        .where((t) => t.type == 'ingreso')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == 'gasto')
        .fold(0.0, (sum, t) => sum + t.amount);

    if (mounted) {
      setState(() {
        _currentIncome = income;
        _currentExpense = expense;

        if (_daysPassed > 0) {
          final dailyAverage = expense / _daysPassed;
          _predictedExpense = dailyAverage * _daysInMonth;
          _predictedBalance = income - _predictedExpense;
        } else {
          _predictedExpense = expense;
          _predictedBalance = income - expense;
        }

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNegative = _predictedBalance < 0;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(l10n.spending_predictions),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: AppState.instance,
              builder: (context, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(l10n),
                      const SizedBox(height: 24),
                      _buildProjectionCard(l10n, isNegative),
                      if (isNegative) ...[
                        const SizedBox(height: 24),
                        _buildWarningCard(l10n),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 30,
      glowColor: AppColors.primaryPurple.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.current_balance.toUpperCase(),
            style: AppTextStyles.subLabel,
          ),
          const SizedBox(height: 16),
          _buildRow(l10n.income, _currentIncome, AppColors.incomeGreen),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.cardBorder, height: 1),
          ),
          _buildRow(l10n.expense, _currentExpense, AppColors.expenseRed),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(AppLocalizations l10n, bool isNegative) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.prediction.toUpperCase(),
            style: AppTextStyles.subLabel.copyWith(
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildProjectionRow(
            "Gasto estimado fin de mes",
            _predictedExpense,
            AppColors.textPrimary,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.cardBorder, height: 1),
          ),
          _buildProjectionRow(
            "Balance estimado",
            _predictedBalance,
            isNegative ? Colors.orangeAccent : AppColors.incomeGreen,
            large: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.expenseRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.expenseRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.expenseRed),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "⚠️ Si continúas gastando a este ritmo terminarás el mes en negativo.",
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.expenseRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            AppState.instance.hideBalance
                ? "••••••"
                : CurrencyHelper.format(value, context),
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18, color: color),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectionRow(
    String label,
    double value,
    Color color, {
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMain.copyWith(
              color: AppColors.textPrimary.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            AppState.instance.hideBalance
                ? "••••••"
                : CurrencyHelper.format(value, context),
            style: AppTextStyles.cardTitle.copyWith(
              color: color,
              fontSize: large ? 28 : 20,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
