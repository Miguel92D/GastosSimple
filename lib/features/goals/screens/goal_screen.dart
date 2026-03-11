import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../controllers/goal_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/state/app_state.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _controller = GoalController.instance;
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final goals = await _controller.loadGoals();
    if (mounted) {
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrEditGoal([Goal? goal]) async {
    final nameController = TextEditingController(text: goal?.name);
    final targetController = TextEditingController(
      text: goal?.targetAmount.toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          goal == null
              ? AppLocalizations.of(context)!.new_goal
              : AppLocalizations.of(context)!.edit_goal,
          style: AppTextStyles.cardTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: AppTextStyles.bodyMain,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.goal_name_label,
                labelStyle: AppTextStyles.bodyMain.copyWith(
                  color: AppColors.textMuted,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              style: AppTextStyles.bodyMain,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.target_label,
                labelStyle: AppTextStyles.bodyMain.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixText: CurrencyHelper.getSymbol(context),
                prefixStyle: AppTextStyles.bodyMain.copyWith(
                  color: AppColors.primaryPurple,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0;
              if (name.isNotEmpty && target > 0) {
                final newGoal = Goal(
                  id: goal?.id,
                  name: name,
                  targetAmount: target,
                  currentAmount: goal?.currentAmount ?? 0.0,
                  targetDate: DateTime.now(),
                  icon: '🚗',
                );
                await _controller.saveGoal(newGoal);
                if (!context.mounted) return;
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (result == true) _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.savings_goals),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: true,
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, child) {
          return SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _goals.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_goals_yet,
                      style: AppTextStyles.bodyMain.copyWith(
                        color: AppColors.softText,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final progress = (goal.currentAmount / goal.targetAmount)
                          .clamp(0.0, 1.0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          borderRadius: 30,
                          glowColor: AppColors.primaryPurple.withOpacity(0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: AppTextStyles.cardTitle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _addOrEditGoal(goal),
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          size: 20,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await _controller.deleteGoal(
                                            goal.id!,
                                          );
                                          _loadGoals();
                                        },
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          size: 20,
                                          color: AppColors.expenseRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppState.instance.hideBalance
                                    ? "•••••• / ••••••"
                                    : '${CurrencyHelper.format(goal.currentAmount, context)} / ${CurrencyHelper.format(goal.targetAmount, context)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.softText,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: AppColors.softText
                                      .withOpacity(0.08),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryPurple,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGoal(),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
