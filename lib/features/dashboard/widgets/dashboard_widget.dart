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
import 'dashboard_period_selector.dart';
import 'income_expense_cards.dart';
import 'daily_allowance_card.dart';
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

  /// Período elegido en el selector (cambia al instante al tocarlo).
  DashboardPeriod _period = DashboardPeriod.month;

  /// Período de los datos que se están MOSTRANDO. Solo cambia cuando llegan
  /// los datos nuevos, así la tarjeta nunca muestra un título de un período
  /// con montos del otro.
  DashboardPeriod _loadedPeriod = DashboardPeriod.month;
  double income = 0;
  double expenses = 0;
  double balance = 0;
  bool isLoading = true;
  String? _filter; // 'ingreso', 'gasto', or null
  int _loadVersion = 0;
  DateTime _loadedMonth = MonthController.instance.selectedMonth;
  // Día visible en modo DÍA (sin hora). Se navega deslizando la tarjeta,
  // igual que los meses.
  DateTime _selectedDay = _today();
  DateTime _loadedDay = _today();
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
    final selectedDay = _selectedDay;
    final period = _period;

    try {
      final data = await controller.loadMovementsByPeriod(
        widget.isVault,
        period: period,
        date: period == DashboardPeriod.month ? selectedMonth : selectedDay,
      );

      if (mounted && loadVersion == _loadVersion) {
        if (period == DashboardPeriod.month &&
            !MonthController.isSameMonth(
              selectedMonth,
              MonthController.instance.selectedMonth,
            )) {
          return;
        }

        setState(() {
          movimientos = data;
          income = controller.calculateIncome(data);
          expenses = controller.calculateExpenses(data);
          balance = controller.calculateBalance(data);
          _loadedMonth = selectedMonth;
          _loadedDay = selectedDay;
          _loadedPeriod = period;
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

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _isViewingToday => _isSameDay(_selectedDay, _today());

  void _changeDay(DateTime day, int exitDirection) {
    _cardExitDirection = exitDirection;
    setState(() => _selectedDay = day);
    loadData();
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

    if (_loadedPeriod != _period) return; // todavía cargando el cambio

    if (_period == DashboardPeriod.day) {
      if (swipeToRight) {
        _changeDay(
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day - 1),
          1,
        );
      } else if (swipeToLeft && !_isViewingToday) {
        _changeDay(
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + 1),
          -1,
        );
      }
      return;
    }

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

    if (_loadedPeriod != _period) return; // todavía cargando el cambio

    // Modo DÍA: tocar la tarjeta vuelve a hoy.
    if (_period == DashboardPeriod.day) {
      if (!_isViewingToday) _changeDay(_today(), -1);
      return;
    }

    final monthController = MonthController.instance;
    if (monthController.isCurrentMonth()) return;

    _cardExitDirection = -1;
    monthController.goToCurrentMonth();
  }

  Widget _buildBalanceCard(BuildContext context) {
    final l10n = context.read<AppLocaleController>();
    final isDay = _loadedPeriod == DashboardPeriod.day;
    final currentKey = ValueKey(
      isDay ? _dayKey(_loadedDay) : _monthKey(_loadedMonth),
    );

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
          // Cambio MES <-> DÍA (dirección 0): fundido suave, sin deslizar.
          if (_cardExitDirection == 0) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
                child: child,
              ),
            );
          }
          final exitDirection = _cardExitDirection;
          final isIncoming = child.key == currentKey;
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
          key: currentKey,
          balance: balance,
          title: (isDay
                  ? l10n.text(
                      _isSameDay(_loadedDay, _today())
                          ? 'today_balance'
                          : 'day_balance',
                    )
                  : l10n.text('monthly_balance'))
              .toUpperCase(),
          subtitle: isDay
              ? L10nHelper.getLocalizedDateDay(context, _loadedDay)
              : L10nHelper.getLocalizedDateMonth(context, _loadedMonth),
        ),
      ),
    );
  }

  String _monthKey(DateTime month) {
    return '${month.year}-${month.month}';
  }

  String _dayKey(DateTime day) {
    return 'day-${day.year}-${day.month}-${day.day}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredMovimientos = _filter == null
        ? movimientos
        : movimientos
              .where((m) => Transaction.normalizeType(m.type) == _filter)
              .toList();

    return SingleChildScrollView(
      // Espacio para que el final de la lista quede por encima de los
      // botones flotantes (+ y − : 2 × 56 + 16 de separación + margen) y de
      // la barra de navegación del sistema. Con 100 fijos, el "+" tapaba
      // montos y textos al llegar al final.
      padding: EdgeInsets.only(
        bottom:
            AppSpacing.xxl * 3 +
            AppSpacing.lg +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Arriba usa xl (32): el resplandor de la tarjeta (GlassCard,
            // blur 30 + spread 2) necesita ese espacio. Con sm (8) el
            // scroll lo recortaba y se veía una línea recta bajo "$imple".
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _buildBalanceCard(context),
          ),
          DashboardPeriodSelector(
            selectedPeriod: _period,
            onPeriodChanged: (newPeriod) {
              if (_period != newPeriod) {
                // Sin spinner de pantalla completa: se sigue mostrando el
                // contenido actual hasta que llegan los datos nuevos y la
                // tarjeta hace un fundido (antes parpadeaba y se deslizaba).
                setState(() {
                  _period = newPeriod;
                  _cardExitDirection = 0;
                  // Al entrar a DÍA siempre se arranca en hoy.
                  if (newPeriod == DashboardPeriod.day) {
                    _selectedDay = _today();
                  }
                });
                loadData();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          IncomeExpenseCards(
            income: income,
            expenses: expenses,
            selectedFilter: _filter,
            onIncomeTap: () => _toggleFilter('ingreso'),
            onExpenseTap: () => _toggleFilter('gasto'),
          ),
          // Solo tiene sentido mirando el presente (mes actual u hoy) y
          // fuera de la Bóveda.
          if (!widget.isVault &&
              ((_loadedPeriod == DashboardPeriod.month &&
                      MonthController.isSameMonth(
                        _loadedMonth,
                        DateTime.now(),
                      )) ||
                  (_loadedPeriod == DashboardPeriod.day &&
                      _isSameDay(_loadedDay, _today()))))
            const DailyAllowanceCard(),
          const SizedBox(height: AppSpacing.md),
          RecentTransactionsList(
            transactions: filteredMovimientos,
            onRefresh: loadData,
            title: _loadedPeriod == DashboardPeriod.day
                ? l10n.text(
                    _isSameDay(_loadedDay, _today())
                        ? 'today_movements'
                        : 'day_movements',
                  )
                : l10n.text('month_movements'),
          ),
        ],
      ),
    );
  }
}
