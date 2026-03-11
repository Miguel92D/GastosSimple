/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/glass_card.dart';

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
      backgroundColor: AppColors.darkBackground,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              AppColors.primaryPurple.withOpacity(0.1),
              AppColors.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl + 8,
                ),
                child: Text(
                  l10n.quick_entry_question,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionCard(
                    context: context,
                    icon: Icons.add_rounded,
                    color: AppColors.incomeGreen,
                    onTap: () => ActionController.execute(
                      context,
                      AppAction.addIncome,
                      arguments: {"isFromQuickEntry": true},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl + 8),
                  _buildActionCard(
                    context: context,
                    icon: Icons.remove_rounded,
                    color: AppColors.expenseRed,
                    onTap: () => ActionController.execute(
                      context,
                      AppAction.addExpense,
                      arguments: {"isFromQuickEntry": true},
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildDashboardButton(context),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        width: 100,
        height: 100,
        padding: EdgeInsets.zero,
        borderRadius: 32,
        glowColor: color.withOpacity(0.3),
        border: Border.all(color: color.withOpacity(0.4), width: 2.0),
        child: Center(child: Icon(icon, color: color, size: 48)),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return GestureDetector(
      onTap: () => ActionController.execute(context, AppAction.openDashboard),
      child: GlassCard(
        width: 80,
        height: 80,
        borderRadius: 32,
        padding: EdgeInsets.zero,
        glowColor: AppColors.primaryPurple.withOpacity(0.4),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.4),
          width: 2.0,
        ),
        child: const Center(
          child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
