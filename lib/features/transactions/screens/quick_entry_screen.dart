import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/entry_amount_card.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';

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
      body: SafeArea(
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
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                EntryAmountCard(
                  title: l10n.income,
                  color: Colors.green,
                  icon: Icons.arrow_upward,
                  onSubmit: (amount) {
                    ActionController.execute(
                      context,
                      AppAction.addIncome,
                      arguments: {"amount": amount, "isFromQuickEntry": true},
                    );
                  },
                ),
                const SizedBox(height: 20),
                EntryAmountCard(
                  title: l10n.expense,
                  color: Colors.red,
                  icon: Icons.arrow_downward,
                  onSubmit: (amount) {
                    ActionController.execute(
                      context,
                      AppAction.addExpense,
                      arguments: {"amount": amount, "isFromQuickEntry": true},
                    );
                  },
                ),
                const SizedBox(height: 48),
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ActionController.execute(
                          context,
                          AppAction.openDashboard,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.dashboard,
                          color: Colors.grey,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
