import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../widgets/transaction_history_list.dart';

import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  List<Transaction> _movimientos = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(_loadData);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final query = _searchController.text.trim();
    final List<Transaction> movimientos;

    if (_isSearching && query.isNotEmpty) {
      movimientos = await TransactionController.search(query);
    } else {
      movimientos = await TransactionController.getNormalHistory();
    }

    if (mounted) {
      setState(() {
        _movimientos = movimientos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "",
      drawer: const AppDrawer(),
      titleWidget: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.watch<AppLocaleController>().text('search'),
                border: InputBorder.none,
                hintStyle: AppTextStyles.bodyMain.copyWith(
                  color: AppColors.softText.withOpacity(0.5),
                ),
              ),
              style: AppTextStyles.bodyMain.copyWith(
                color: AppColors.textPrimary,
              ),
              onChanged: (_) => _loadData(),
            )
          : Text(
              context.watch<AppLocaleController>().text('movements'),
              style: AppTextStyles.titleLarge.copyWith(fontSize: 24, letterSpacing: -1),
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _searchController.clear();
                _loadData();
              }
              _isSearching = !_isSearching;
            });
          },
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: TransactionHistoryList(
                transactions: _movimientos,
                onRefresh: _loadData,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
    );
  }
}
