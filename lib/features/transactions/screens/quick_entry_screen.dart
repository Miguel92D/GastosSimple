import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                l10n.quick_entry_question,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        label: l10n.income,
                        icon: Icons.add_rounded,
                        color: AppColors.income,
                        onTap: () => ActionController.execute(
                          context,
                          AppAction.addIncome,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        label: l10n.expense,
                        icon: Icons.remove_rounded,
                        color: AppColors.expense,
                        onTap: () => ActionController.execute(
                          context,
                          AppAction.addExpense,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildDashboardButton(context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 40),
        borderRadius: 32,
        glowColor: color.withValues(alpha: 0.2),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return GestureDetector(
      onTap: () => ActionController.execute(context, AppAction.openDashboard),
      child: GlassCard(
        borderRadius: 50,
        padding: const EdgeInsets.all(16),
        glowColor: AppColors.primaryStart.withValues(alpha: 0.3),
        child: const Icon(
          Icons.grid_view_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
