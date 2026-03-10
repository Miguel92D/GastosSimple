import 'package:flutter/material.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/app_fab.dart';
import '../widgets/dashboard_widget.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../core/notifiers/transaction_notifier.dart';

import '../../../core/ui/widgets/gold_shimmer_text.dart';
import '../../../core/state/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await TransactionController.processRecurringTransactions();
    TransactionNotifier.instance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "\$imple",
      titleWidget: GoldShimmerText(
        text: "\$imple",
        isPro: AppState.instance.isPro,
        fontSize: 24,
      ),
      drawer: const AppDrawer(),
      floatingActionButton: const AppFAB(),
      body: const DashboardWidget(),
    );
  }
}
