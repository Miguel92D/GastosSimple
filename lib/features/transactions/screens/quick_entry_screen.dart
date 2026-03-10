import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/entry_amount_card.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';
import '../../../core/flow/transaction_flow_service.dart';
import '../models/transaction.dart';
import '../../../core/ui/design/app_colors.dart';
import '../../../core/ui/widgets/glass_card.dart';

class QuickEntryScreen extends StatefulWidget {
  const QuickEntryScreen({super.key});

  @override
  State<QuickEntryScreen> createState() => _QuickEntryScreenState();
}

class _QuickEntryScreenState extends State<QuickEntryScreen> {
  @override
  void initState() {
    super.initState();
    _checkPendingAction();
  }

  Future<void> _checkPendingAction() async {
    final prefs = await SharedPreferences.getInstance();
    final action = prefs.getString('pending_action');

    if (action == 'quick_entry' && mounted) {
      final type = prefs.getString('pending_type') ?? 'gasto';

      await prefs.remove('pending_action');
      await prefs.remove('pending_type');

      if (mounted) {
        ActionController.execute(
          context,
          type == 'ingreso' ? AppAction.addIncome : AppAction.addExpense,
          arguments: {"isFromQuickEntry": true},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              AppColors.primaryStart.withValues(alpha: 0.1),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    l10n.quick_entry_question,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  EntryAmountCard(
                    title: l10n.income,
                    color: AppColors.income,
                    icon: Icons.add_rounded,
                    onSubmit: (amount) {
                      final transaction = Transaction(
                        amount: amount,
                        category: 'Otros',
                        type: 'ingreso',
                        date: DateTime.now(),
                      );
                      TransactionFlowService.instance.saveTransaction(
                        context,
                        transaction,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  EntryAmountCard(
                    title: l10n.expense,
                    color: AppColors.expense,
                    icon: Icons.remove_rounded,
                    onSubmit: (amount) {
                      final transaction = Transaction(
                        amount: amount,
                        category: 'Otros',
                        type: 'gasto',
                        date: DateTime.now(),
                      );
                      TransactionFlowService.instance.saveTransaction(
                        context,
                        transaction,
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: () {
                      ActionController.execute(
                        context,
                        AppAction.openDashboard,
                      );
                    },
                    child: GlassCard(
                      borderRadius: 40,
                      padding: const EdgeInsets.all(16),
                      glowColor: AppColors.primaryStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Ver Dashboard",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
