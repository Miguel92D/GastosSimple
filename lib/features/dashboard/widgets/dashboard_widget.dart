import 'package:flutter/material.dart';
import '../controllers/dashboard_controller.dart';
import '../../transactions/models/transaction.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/ui/widgets/balance_card.dart';
import 'income_expense_cards.dart';
import 'recent_transactions_list.dart';

class DashboardWidget extends StatefulWidget {
  final bool isVault;

  const DashboardWidget({super.key, this.isVault = false});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final DashboardController controller = DashboardController();
  List<Transaction> movimientos = [];

  double income = 0;
  double expenses = 0;
  double balance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    TransactionNotifier.instance.addListener(loadData);
    loadData();
  }

  @override
  void dispose() {
    TransactionNotifier.instance.removeListener(loadData);
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final data = await controller.loadMovements(widget.isVault);

      if (mounted) {
        setState(() {
          movimientos = data;
          income = controller.calculateIncome(data);
          expenses = controller.calculateExpenses(data);
          balance = controller.calculateBalance(data);
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: BalanceCard(balance: balance),
          ),
          IncomeExpenseCards(income: income, expenses: expenses),
          const SizedBox(height: 16),
          RecentTransactionsList(
            transactions: movimientos,
            onRefresh: loadData,
          ),
        ],
      ),
    );
  }
}
