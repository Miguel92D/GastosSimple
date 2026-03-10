import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../widgets/transaction_history_list.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
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
            : Text(AppLocalizations.of(context)!.movements),
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
      ),
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
