import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/savings_goal_controller.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/ui/app_button.dart';
import '../models/goal.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import 'package:gastos_simple/core/ui/widgets/app_action_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_empty_state.dart';
import 'package:gastos_simple/core/ui/widgets/app_progress_bar.dart';
import 'package:gastos_simple/core/ui/widgets/app_round_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_section_title.dart';
import 'package:gastos_simple/core/ui/widgets/app_sheet.dart';
import 'package:gastos_simple/core/ui/widgets/glass_input.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final _controller = SavingsGoalController.instance;

  @override
  void initState() {
    super.initState();
    _controller.loadGoals();
  }

  void _showCreateGoalModal([Goal? goal]) {
    AppSheet.show<void>(
      context,
      builder: (context) => _CreateGoalModal(
        goal: goal,
        onSave: (newGoal) {
          if (goal == null) {
            _controller.createGoal(newGoal);
          } else {
            _controller.updateGoal(newGoal);
          }
        },
      ),
    );
  }

  void _showAddMoneyModal(Goal goal) {
    AppSheet.show<void>(
      context,
      builder: (context) => _AddMoneyModal(
        goal: goal,
        onAdd: (amount) async {
          await _controller.addMoneyToGoal(goal.id!, amount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.read<AppLocaleController>();
    return AppScaffold(
      title: l10n.text('savings_goals'),
      drawer: const AppDrawer(),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryCard(
                  totalSaved: _controller.totalSaved,
                  activeGoals: _controller.activeGoalsCount,
                ),
                const SizedBox(height: AppSpacing.lg),
                ..._controller.goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _GoalItemCard(
                      goal: goal,
                      onEdit: () => _showCreateGoalModal(goal),
                      onDelete: () => _controller.deleteGoal(goal.id!),
                      onAddMoney: () => _showAddMoneyModal(goal),
                    ),
                  ),
                ),
                if (_controller.goals.isEmpty)
                  AppEmptyState(
                    icon: AppIcons.goals,
                    text: l10n.text('no_goals_message'),
                  ),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildAddGoalFab(context),
    );
  }

  Widget _buildAddGoalFab(BuildContext context) {
    return AppRoundButton(
      icon: AppIcons.add,
      onTap: () => _showCreateGoalModal(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalSaved;
  final int activeGoals;

  const _SummaryCard({required this.totalSaved, required this.activeGoals});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppRadius.xl,
      padding:
          EdgeInsets.zero, // el relleno lo da el Padding interno (antes 24+24)
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('total_savings').toUpperCase(),
              style: AppTextStyles.subLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: totalSaved),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.fastOutSlowIn,
              builder: (context, value, _) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyHelper.formatPrivate(value, context),
                    style: AppTextStyles.incomeValue.copyWith(fontSize: 36),
                    maxLines: 1,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('active_goals', {'count': activeGoals.toString()}),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalItemCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddMoney;

  const _GoalItemCard({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<AppLocaleController>(context, listen: false);
    final progress = goal.progress;
    final percentage = (progress * 100).toInt();
    final dateFormat = DateFormat('MMM yyyy', l10n.locale);

    return GlassCard(
      borderRadius: AppRadius.lg,
      padding:
          EdgeInsets.zero, // el relleno lo da el Padding interno (antes 24+16)
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(goal.name, style: AppTextStyles.cardTitle),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: goal.currentAmount),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text(
                  '${CurrencyHelper.formatPrivate(value, context)} / ${CurrencyHelper.formatPrivate(goal.targetAmount, context)}',
                  style: AppTextStyles.bodyMain.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppProgressBar(value: progress),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$percentage%',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Provider.of<AppLocaleController>(
                          context,
                          listen: false,
                        ).text('need_to_save').toUpperCase(),
                        style: AppTextStyles.subLabel,
                      ),
                      Text(
                        '${CurrencyHelper.formatPrivate(SavingsGoalController.instance.calculateMonthlySaving(goal), context)} / ${l10n.text('per_month')}',
                        style: AppTextStyles.bodyMain.copyWith(
                          color: AppColors.incomeGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${l10n.text('estimated_date')}: ${dateFormat.format(goal.targetDate)}',
              style: AppTextStyles.bodySmall,
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppActionButton(
                  icon: AppIcons.pay,
                  color: AppColors.incomeGreen,
                  onTap: onAddMoney,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppActionButton(
                  icon: AppIcons.edit,
                  color: AppColors.primaryPurple,
                  onTap: onEdit,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppActionButton(
                  icon: AppIcons.delete,
                  color: AppColors.expenseRed,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateGoalModal extends StatefulWidget {
  final Goal? goal;
  final Function(Goal) onSave;

  const _CreateGoalModal({this.goal, required this.onSave});

  @override
  State<_CreateGoalModal> createState() => _CreateGoalModalState();
}

class _CreateGoalModalState extends State<_CreateGoalModal> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _targetDate;
  late String _selectedIcon;
  late TextEditingController _dateController;

  final List<String> _icons = [
    '🚗',
    '🏠',
    '✈️',
    '🎮',
    '💻',
    '💍',
    '🎓',
    '🏖️',
    '💰',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');

    final initialAmount = widget.goal?.targetAmount ?? 0;
    final initialAmountText = initialAmount == 0
        ? ''
        : CurrencyHelper.formatAmountForInput(initialAmount);
    _amountController = TextEditingController(text: initialAmountText);
    _targetDate =
        widget.goal?.targetDate ??
        DateTime.now().add(const Duration(days: 365));
    _selectedIcon = widget.goal?.icon ?? '🚗';
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_targetDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetTitle(
              widget.goal == null
                  ? Provider.of<AppLocaleController>(
                      context,
                      listen: false,
                    ).text('new_goal')
                  : Provider.of<AppLocaleController>(
                      context,
                      listen: false,
                    ).text('edit_goal'),
            ),
            _buildFieldLabel(
              Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('goal_name_label'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildGlassInput(
              controller: _nameController,
              hintText: Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('goal_name_hint'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFieldLabel(
              Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('target_label'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildGlassInput(
              controller: _amountController,
              hintText: '0.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              prefix: Text(
                '${CurrencyHelper.getSymbol(context)} ',
                style: AppTextStyles.bodyMain,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFieldLabel(
              Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('estimated_date'),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassInput(
              controller: _dateController,
              label: '',
              icon: AppIcons.day,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  setState(() {
                    _targetDate = picked;
                    _dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(picked);
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFieldLabel(
              Provider.of<AppLocaleController>(
                context,
                listen: false,
              ).text('icon_label'),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIcon == _icons[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = _icons[index]),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple.withValues(alpha: 0.2)
                            : AppColors.glassSurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(_icons[index], style: AppTextStyles.emoji),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              onTap: () {
                final name = _nameController.text.trim();
                double amount =
                    CurrencyHelper.parseAmount(_amountController.text) ?? 0.0;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Provider.of<AppLocaleController>(
                          context,
                          listen: false,
                        ).text('goal_name_required'),
                      ),
                    ),
                  );
                  return;
                }

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Provider.of<AppLocaleController>(
                          context,
                          listen: false,
                        ).text('goal_amount_required'),
                      ),
                    ),
                  );
                  return;
                }

                widget.onSave(
                  Goal(
                    id: widget.goal?.id,
                    name: name,
                    targetAmount: amount,
                    currentAmount: widget.goal?.currentAmount ?? 0,
                    targetDate: _targetDate,
                    icon: _selectedIcon,
                    createdAt: widget.goal?.createdAt ?? DateTime.now(),
                  ),
                );
                Navigator.pop(context);
              },
              color: AppColors.primaryPurple,
              label: widget.goal == null
                  ? Provider.of<AppLocaleController>(
                      context,
                      listen: false,
                    ).text('create_goal_button')
                  : Provider.of<AppLocaleController>(
                      context,
                      listen: false,
                    ).text('save_changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: AppTextStyles.subLabel);
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    Widget? prefix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return GlassInput(
      controller: controller,
      label: '',
      hintText: hintText,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      prefix: prefix,
    );
  }
}

class _AddMoneyModal extends StatefulWidget {
  final Goal goal;
  final Function(double) onAdd;

  const _AddMoneyModal({required this.goal, required this.onAdd});

  @override
  State<_AddMoneyModal> createState() => _AddMoneyModalState();
}

class _AddMoneyModalState extends State<_AddMoneyModal> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _add() {
    final amount = CurrencyHelper.parseAmount(_amountController.text) ?? 0.0;
    if (amount > 0) {
      widget.onAdd(amount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<AppLocaleController>(context, listen: false);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetTitle(
              l10n.text('add_money_to', {'name': widget.goal.name}),
            ),
            AppSectionTitle(l10n.text('amount_to_add'), spaceAbove: false),
            GlassInput(
              controller: _amountController,
              label: '',
              hintText: '0.00',
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              prefix: Text(
                '${CurrencyHelper.getSymbol(context)} ',
                style: AppTextStyles.bodyMain,
              ),
              onSubmitted: _add,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              onTap: _add,
              color: AppColors.primaryPurple,
              label: l10n.text('add_label'),
            ),
          ],
        ),
      ),
    );
  }
}
