import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../core/controllers/savings_goal_controller.dart';
import '../models/goal.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    return AppScaffold(
      title: 'Metas de ahorro',
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
                ..._controller.goals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _GoalItemCard(
                        goal: goal,
                        onEdit: () => _showCreateGoalModal(goal),
                        onDelete: () => _controller.deleteGoal(goal.id!),
                        onAddMoney: () => _showAddMoneyModal(goal),
                      ),
                    )),
                if (_controller.goals.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: Text(
                        'No tienes metas de ahorro aún.',
                        style: AppTextStyles.bodyMain,
                      ),
                    ),
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
    return GlassCard(
      width: 56,
      height: 56,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      glowColor: AppColors.primaryPurple.withValues(alpha: 0.3),
      border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4), width: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCreateGoalModal(),
          borderRadius: BorderRadius.circular(18),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: AppColors.primaryPurple,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalSaved;
  final int activeGoals;

  const _SummaryCard({
    required this.totalSaved,
    required this.activeGoals,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppRadius.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Text(
              'AHORROS TOTALES',
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
                    CurrencyHelper.format(value, context),
                    style: AppTextStyles.incomeValue.copyWith(
                      fontSize: 36,
                    ),
                    maxLines: 1,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$activeGoals metas activas',
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
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final dateFormat = DateFormat('MMM yyyy');

    return GlassCard(
      borderRadius: AppRadius.lg,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    goal.name,
                    style: AppTextStyles.cardTitle,
                  ),
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
                  '${CurrencyHelper.format(value, context)} / ${CurrencyHelper.format(goal.targetAmount, context)}',
                  style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: AppGradients.progressGradient,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
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
                      const Text('Necesitas ahorrar:', style: AppTextStyles.subLabel),
                      Text(
                        '${CurrencyHelper.format(SavingsGoalController.instance.calculateMonthlySaving(goal), context)} / mes',
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
              'Meta estimada: ${dateFormat.format(goal.targetDate)}',
              style: AppTextStyles.bodySmall,
            ),
            const Divider(color: Colors.white10, height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.payments_rounded,
                  color: AppColors.incomeGreen,
                  onTap: onAddMoney,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: AppColors.primaryPurple,
                  onTap: onEdit,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Center(
          child: Icon(icon, size: 18, color: color),
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

  final List<String> _icons = ['🚗', '🏠', '✈️', '🎮', '💻', '💍', '🎓', '🏖️', '💰'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _amountController = TextEditingController(
        text: widget.goal?.targetAmount.toString() ?? '');
    _targetDate = widget.goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));
    _selectedIcon = widget.goal?.icon ?? '🚗';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: GlassCard(
            borderRadius: 30,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text(
                widget.goal == null ? 'Nueva Meta' : 'Editar Meta',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFieldLabel('Nombre de la meta'),
              const SizedBox(height: AppSpacing.sm),
              _buildGlassInput(
                controller: _nameController,
                hintText: 'Ej: Mi primer auto',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildFieldLabel('Monto objetivo'),
              const SizedBox(height: AppSpacing.sm),
              _buildGlassInput(
                controller: _amountController,
                hintText: '0.00',
                keyboardType: TextInputType.number,
                prefix: Text(CurrencyHelper.getSymbol(context) + ' ',
                    style: AppTextStyles.bodyMain),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildFieldLabel('Fecha estimada'),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setState(() => _targetDate = picked);
                  }
                },
                child: _buildGlassInputContainer(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.softText, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text(DateFormat('dd/MM/yyyy').format(_targetDate),
                          style: AppTextStyles.bodyMain),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildFieldLabel('Icono'),
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
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(_icons[index],
                            style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  // Clean the amount string to handle different decimal/thousands separators
                  String amountText = _amountController.text
                      .replaceAll(' ', '')
                      .replaceAll('.', '') // Assuming . is thousand separator
                      .replaceAll(',', '.'); // Assuming , is decimal separator
                  
                  // If after cleaning there is more than one dot, it might have been formatted differently
                  // Let's try a fallback: if it doesn't parse, try parsing the original without symbols
                  double? amount = double.tryParse(amountText);
                  if (amount == null) {
                    amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
                  }
                  
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, ingresa un nombre para la meta')),
                    );
                    return;
                  }
                  
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, ingresa un monto objetivo válido mayor a 0')),
                    );
                    return;
                  }

                  widget.onSave(Goal(
                    id: widget.goal?.id,
                    name: name,
                    targetAmount: amount,
                    currentAmount: widget.goal?.currentAmount ?? 0,
                    targetDate: _targetDate,
                    icon: _selectedIcon,
                    createdAt: widget.goal?.createdAt ?? DateTime.now(),
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  widget.goal == null ? 'Crear Meta' : 'Guardar Cambios',
                  style: AppTextStyles.buttonLabel,
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

  Widget _buildFieldLabel(String label) {
    return Text(label, style: AppTextStyles.subLabel);
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    Widget? prefix,
    VoidCallback? onSubmitted,
    TextInputAction? textInputAction,
  }) {
    return _buildGlassInputContainer(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction ?? TextInputAction.done,
        onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
        style: AppTextStyles.bodyMain,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          border: InputBorder.none,
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: prefix,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  Widget _buildGlassInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: GlassCard(
            borderRadius: 30,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Agregar dinero a ${widget.goal.name}',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Monto a agregar', style: AppTextStyles.subLabel),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        final amount = double.tryParse(value) ?? 0;
                        if (amount > 0) {
                          widget.onAdd(amount);
                          Navigator.pop(context);
                        }
                      },
                      autofocus: true,
                      style: AppTextStyles.bodyMain,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        prefixText: CurrencyHelper.getSymbol(context) + ' ',
                        prefixStyle: AppTextStyles.bodyMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text) ?? 0;
                      if (amount > 0) {
                        widget.onAdd(amount);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Agregar', style: AppTextStyles.buttonLabel),
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
