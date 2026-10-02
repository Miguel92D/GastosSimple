import 'dart:io';

import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../utils/transaction_csv.dart';
import '../utils/transaction_filter.dart';
import '../widgets/transaction_history_list.dart';

import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/money.dart';

class MovementsScreen extends StatefulWidget {
  /// Filtro inicial (ej. desde Estadísticas: categoría + mes).
  final TransactionFilter? initialFilter;

  const MovementsScreen({super.key, this.initialFilter});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  List<Transaction> _all = [];
  bool _isLoading = true;
  bool _isSearching = false;
  TransactionFilter _filter = const TransactionFilter();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) _filter = widget.initialFilter!;
    TransactionNotifier.instance.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(_loadData);
    _searchController.dispose();
    super.dispose();
  }

  /// Carga el historial una vez; búsqueda y filtros se aplican en memoria
  /// (antes cada tecla mostraba el spinner y volvía a consultar la base).
  Future<void> _loadData() async {
    if (!mounted) return;
    final movimientos = await TransactionController.getNormalHistory();
    if (mounted) {
      setState(() {
        _all = movimientos;
        _isLoading = false;
      });
    }
  }

  /// Exporta a CSV exactamente lo que se ve (con los filtros aplicados).
  Future<void> _exportCsv(
    AppLocaleController l10n,
    List<Transaction> items,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (items.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.text('export_csv_empty'))),
      );
      return;
    }
    try {
      final csv = TransactionCsv.build(
        items,
        headers: [
          l10n.text('date'),
          l10n.text('csv_type'),
          l10n.text('category'),
          l10n.text('amount'),
          l10n.text('note'),
        ],
        typeLabels: (
          income: l10n.text('csv_income'),
          expense: l10n.text('csv_expense'),
        ),
        localize: (c) => L10nHelper.getLocalizedCategory(context, c),
      );
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/simple_movimientos_$stamp.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        text: l10n.text('export_csv_share_text', {
          'n': items.length.toString(),
        }),
      );
    } catch (e) {
      debugPrint('CSV export error: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.text('export_csv_error'))),
      );
    }
  }

  void _setFilter(TransactionFilter filter) {
    HapticFeedback.selectionClick();
    setState(() => _filter = filter);
  }

  Future<void> _pickCategories(AppLocaleController l10n) async {
    final available = _all.map((t) => t.category).toSet().toList()
      ..sort(
        (a, b) => L10nHelper.getLocalizedCategory(context, a)
            .compareTo(L10nHelper.getLocalizedCategory(context, b)),
      );
    final selected = {..._filter.categories};

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: AppColors.darkBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.text('categories'),
                          style: AppTextStyles.subLabel,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setSheetState(selected.clear),
                        child: Text(l10n.text('filter_clear')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, selected),
                        child: Text(l10n.text('filter_apply')),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final c in available)
                        CheckboxListTile(
                          value: selected.contains(c),
                          activeColor: AppColors.primaryPurple,
                          title: Text(
                            L10nHelper.getLocalizedCategory(context, c),
                          ),
                          onChanged: (v) => setSheetState(() {
                            if (v == true) {
                              selected.add(c);
                            } else {
                              selected.remove(c);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      _setFilter(_filter.copyWith(categories: result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final filtered = _filter.apply(
      _all,
      now: DateTime.now(),
      localize: (c) => L10nHelper.getLocalizedCategory(context, c),
    );

    return AppScaffold(
      title: "",
      drawer: const AppDrawer(),
      titleWidget: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.text('search'),
                border: InputBorder.none,
                hintStyle: AppTextStyles.bodyMain.copyWith(
                  color: AppColors.softText.withValues(alpha: 0.5),
                ),
              ),
              style: AppTextStyles.bodyMain.copyWith(
                color: AppColors.textPrimary,
              ),
              onChanged: (value) =>
                  setState(() => _filter = _filter.copyWith(query: value)),
            )
          : Text(
              l10n.text('movements'),
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 24,
                letterSpacing: -1,
              ),
            ),
      actions: [
        IconButton(
          tooltip: l10n.text('export_csv'),
          icon: const Icon(Icons.ios_share_rounded),
          onPressed: () => _exportCsv(l10n, filtered),
        ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _searchController.clear();
                _filter = _filter.copyWith(query: '');
              }
              _isSearching = !_isSearching;
            });
          },
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(l10n),
                _buildSummary(l10n, filtered),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: TransactionHistoryList(
                      transactions: filtered,
                      onRefresh: _loadData,
                      emptyMessage: _filter.isActive
                          ? l10n.text('filter_no_results')
                          : null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar(AppLocaleController l10n) {
    final categoryCount = _filter.categories.length;
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        children: [
          _FilterPill(
            label: l10n.text('filter_expenses'),
            isSelected: _filter.type == TypeFilter.expense,
            color: AppColors.expenseRed,
            onTap: () => _setFilter(_filter.copyWith(
              type: _filter.type == TypeFilter.expense
                  ? TypeFilter.all
                  : TypeFilter.expense,
            )),
          ),
          _FilterPill(
            label: l10n.text('filter_incomes'),
            isSelected: _filter.type == TypeFilter.income,
            color: AppColors.incomeGreen,
            onTap: () => _setFilter(_filter.copyWith(
              type: _filter.type == TypeFilter.income
                  ? TypeFilter.all
                  : TypeFilter.income,
            )),
          ),
          _FilterPill(
            label: categoryCount == 0
                ? l10n.text('categories')
                : '${l10n.text('categories')} ($categoryCount)',
            icon: Icons.tune_rounded,
            isSelected: categoryCount > 0,
            color: AppColors.primaryPurple,
            onTap: () => _pickCategories(l10n),
          ),
          if (_filter.period == PeriodFilter.specificMonth)
            _FilterPill(
              label: L10nHelper.getLocalizedDateMonth(
                context,
                _filter.month ?? DateTime.now(),
              ),
              icon: Icons.close_rounded,
              isSelected: true,
              color: AppColors.primaryPurple,
              onTap: () =>
                  _setFilter(_filter.copyWith(period: PeriodFilter.all)),
            ),
          for (final p in const [
            PeriodFilter.thisMonth,
            PeriodFilter.lastMonth,
            PeriodFilter.last3Months,
          ])
            _FilterPill(
              label: l10n.text(switch (p) {
                PeriodFilter.thisMonth => 'filter_this_month',
                PeriodFilter.lastMonth => 'filter_last_month',
                _ => 'filter_last_3_months',
              }),
              isSelected: _filter.period == p,
              color: AppColors.primaryPurple,
              onTap: () => _setFilter(_filter.copyWith(
                period: _filter.period == p ? PeriodFilter.all : p,
              )),
            ),
          if (_filter.isActive)
            _FilterPill(
              label: l10n.text('filter_clear'),
              icon: Icons.close_rounded,
              isSelected: false,
              color: AppColors.softText,
              onTap: () {
                _searchController.clear();
                _setFilter(const TransactionFilter());
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(AppLocaleController l10n, List<Transaction> items) {
    if (!_filter.isActive) return const SizedBox.shrink();
    final expense = items
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => Money.round(s + t.amount));
    final income = items
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => Money.round(s + t.amount));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Text(
            l10n.text('filter_count', {'n': items.length.toString()}),
            style: AppTextStyles.subLabel,
          ),
          const Spacer(),
          if (income > 0)
            Text(
              '+${CurrencyHelper.formatPrivate(income, context)}  ',
              style: AppTextStyles.subLabel.copyWith(
                color: AppColors.incomeGreen,
              ),
            ),
          if (expense > 0)
            Text(
              '-${CurrencyHelper.formatPrivate(expense, context)}',
              style: AppTextStyles.subLabel.copyWith(
                color: AppColors.expenseRed,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.85)
                : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? AppColors.textPrimary.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? AppColors.textPrimary : color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.textPrimary : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
