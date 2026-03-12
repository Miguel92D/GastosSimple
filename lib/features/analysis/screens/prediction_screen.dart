import 'dart:math' as math;
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
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
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
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    TransactionNotifier.instance.addListener(_calculatePrediction);
    _calculatePrediction();
  }

  @override
  void dispose() {
    _waveController.dispose();
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

    return AppScaffold(
      title: l10n.spending_predictions,
      drawer: const AppDrawer(),
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
            style: AppTextStyles.subLabel.copyWith(
              color: AppColors.softText.withOpacity(0.5),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildRow(l10n.income, _currentIncome, AppColors.incomeGreen),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: AppColors.cardBorder,
              height: 1,
              thickness: 0.5,
            ),
          ),
          _buildRow(l10n.expense, _currentExpense, AppColors.expenseRed),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(AppLocalizations l10n, bool isNegative) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WavePainter(_waveController.value),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    l10n.prediction.toUpperCase(),
                    style: AppTextStyles.subLabel.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProjectionRow(
                    l10n.estimated_spending,
                    _predictedExpense,
                    AppColors.expenseRed,
                  ),
                  const SizedBox(height: 32),
                  _buildProjectionRow(
                    l10n.estimated_balance,
                    _predictedBalance,
                    _predictedBalance >= 0
                        ? AppColors.incomeGreen
                        : AppColors.expenseRed,
                    large: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      glowColor: AppColors.expenseRed.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.expenseRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.expenseRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.prediction_negative_warning,
              style: AppTextStyles.bodyMain.copyWith(
                color: AppColors.expenseRed,
                fontWeight: FontWeight.w800,
                fontSize: 14,
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
            style: AppTextStyles.bodyMain.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppState.instance.hideBalance
                  ? "••••••"
                  : CurrencyHelper.format(value, context),
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.right,
            ),
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
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
              fontSize: large ? 16 : 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppState.instance.hideBalance
                  ? "••••••"
                  : CurrencyHelper.format(value, context),
              style: AppTextStyles.cardTitle.copyWith(
                color: value == 0 ? Colors.white : color,
                fontSize: large ? 32 : 22,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    final double yCenter = size.height * 0.52;
    final double amplitude = 18.0;

    path.moveTo(0, yCenter);

    for (double x = 0; x <= size.width; x += 1) {
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + amplitude * math.sin(waveExpression);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw secondary fainter line
    final secondaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final secondaryPath = Path();
    secondaryPath.moveTo(0, yCenter + 15);
    for (double x = 0; x <= size.width; x += 1) {
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) - (animationValue * 2 * math.pi);
      final double y =
          yCenter + 15 + (amplitude * 0.6) * math.cos(waveExpression);
      secondaryPath.lineTo(x, y);
    }
    canvas.drawPath(secondaryPath, secondaryPaint);

    // Draw glowing dots along the main path
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 1; i < 4; i++) {
      final x = (size.width / 4) * i;
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + amplitude * math.sin(waveExpression);

      canvas.drawCircle(Offset(x, y), 5, glowPaint);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
