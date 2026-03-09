import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../widgets/transaction_history_list.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/notifiers/transaction_notifier.dart';

class FilteredHistoryScreen extends StatefulWidget {
  final String tipo;

  const FilteredHistoryScreen({super.key, required this.tipo});

  @override
  State<FilteredHistoryScreen> createState() => _FilteredHistoryScreenState();
}

class _FilteredHistoryScreenState extends State<FilteredHistoryScreen> {
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
      movimientos = await TransactionController.searchByType(
        query,
        widget.tipo,
      );
    } else {
      movimientos = widget.tipo == 'ingreso'
          ? await TransactionController.getIncome()
          : await TransactionController.getExpense();
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
    final title = widget.tipo == 'ingreso'
        ? AppLocalizations.of(context)!.income_history
        : AppLocalizations.of(context)!.expense_history;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => _loadData(),
              )
            : Text(title),
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
          : TransactionHistoryList(
              transactions: _movimientos,
              onRefresh: _loadData,
            ),
    );
  }
}
