import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';

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

        // Logic: average expense per day * total days in month
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
      appBar: AppBar(
        title: Flexible(
          child: Text(
            l10n.spending_predictions,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
            ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.current_balance.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildRow(l10n.income, _currentIncome, Colors.green),
            const Divider(height: 24),
            _buildRow(l10n.expense, _currentExpense, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionCard(AppLocalizations l10n, bool isNegative) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.prediction.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildProjectionRow(
            "Gasto estimado fin de mes",
            _predictedExpense,
            Colors.white,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          _buildProjectionRow(
            "Balance estimado",
            _predictedBalance,
            isNegative ? Colors.orangeAccent : Colors.greenAccent,
            large: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "⚠️ Si continúas gastando a este ritmo terminarás el mes en negativo.",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            CurrencyHelper.format(value, context),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            CurrencyHelper.format(value, context),
            style: TextStyle(
              color: color,
              fontSize: large ? 24 : 18,
              fontWeight: FontWeight.bold,
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
