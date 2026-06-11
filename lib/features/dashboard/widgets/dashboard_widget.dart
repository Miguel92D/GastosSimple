/// This project uses a centralized design system.
/// Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
/// All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/dashboard_controller.dart';
import '../../transactions/models/transaction.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/state/month_controller.dart';
import '../../../core/ui/widgets/balance_card.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/utils/l10n_helper.dart';
import 'income_expense_cards.dart';
import 'recent_transactions_list.dart';

class DashboardWidget extends StatefulWidget {
  final bool isVault;

  const DashboardWidget({super.key, this.isVault = false});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  static const double _minimumSwipeDistance = 48;
  static const double _minimumSwipeVelocity = 300;

  final DashboardController controller = DashboardController();
  List<Transaction> movimientos = [];

  double income = 0;
  double expenses = 0;
  double balance = 0;
  bool isLoading = true;
  String? _filter; // 'ingreso', 'gasto', or null
  int _loadVersion = 0;
  DateTime _loadedMonth = MonthController.instance.selectedMonth;
  double _horizontalDragDistance = 0;
  int _cardExitDirection = 0;
  DateTime? _lastBalanceSwipeAt;

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(loadData);
    MonthController.instance.addListener(loadData);
    loadData();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(loadData);
    MonthController.instance.removeListener(loadData);
    super.dispose();
  }

  Future<void> loadData() async {
    final loadVersion = ++_loadVersion;
    final selectedMonth = MonthController.instance.selectedMonth;

    try {
      final data = await controller.loadMovements(
        widget.isVault,
        month: selectedMonth,
      );

      if (mounted &&
          loadVersion == _loadVersion &&
          MonthController.isSameMonth(
            selectedMonth,
            MonthController.instance.selectedMonth,
          )) {
        setState(() {
          movimientos = data;
          income = controller.calculateIncome(data);
          expenses = controller.calculateExpenses(data);
          balance = controller.calculateBalance(data);
          _loadedMonth = selectedMonth;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _toggleFilter(String type) {
    setState(() {
      if (_filter == type) {
        _filter = null;
      } else {
        _filter = type;
      }
    });
  }

  void _handleBalanceDragStart(DragStartDetails details) {
    _horizontalDragDistance = 0;
  }

  void _handleBalanceDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.delta.dx;
  }

  void _handleBalanceSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final distance = _horizontalDragDistance;
    _horizontalDragDistance = 0;

    if (distance.abs() < _minimumSwipeDistance &&
        velocity.abs() < _minimumSwipeVelocity) {
      return;
    }

    _lastBalanceSwipeAt = DateTime.now();

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

  void _goToCurrentMonthFromBalanceCard() {
    final lastSwipeAt = _lastBalanceSwipeAt;
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

  Widget _buildBalanceCard(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _goToCurrentMonthFromBalanceCard,
      onHorizontalDragStart: _handleBalanceDragStart,
      onHorizontalDragUpdate: _handleBalanceDragUpdate,
      onHorizontalDragEnd: _handleBalanceSwipe,
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
        child: BalanceCard(
          key: ValueKey(_monthKey(_loadedMonth)),
          balance: balance,
          title: context
              .read<AppLocaleController>()
              .text('monthly_balance')
              .toUpperCase(),
          subtitle: L10nHelper.getLocalizedDateMonth(context, _loadedMonth),
        ),
      ),
    );
  }

  String _monthKey(DateTime month) {
    return '${month.year}-${month.month}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredMovimientos = _filter == null
        ? movimientos
        : movimientos
              .where((m) => Transaction.normalizeType(m.type) == _filter)
              .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: _buildBalanceCard(context),
          ),
          IncomeExpenseCards(
            income: income,
            expenses: expenses,
            selectedFilter: _filter,
            onIncomeTap: () => _toggleFilter('ingreso'),
            onExpenseTap: () => _toggleFilter('gasto'),
          ),
          const SizedBox(height: AppSpacing.md),
          RecentTransactionsList(
            transactions: filteredMovimientos,
            onRefresh: loadData,
          ),
        ],
      ),
    );
  }
}
