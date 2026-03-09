import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../controllers/goal_controller.dart';

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
        title: Text(
          goal == null
              ? AppLocalizations.of(context)!.new_goal
              : AppLocalizations.of(context)!.edit_goal,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.goal_name_label,
              ),
            ),
            TextField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.target_label,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
                  savedAmount: goal?.savedAmount ?? 0.0,
                );
                await _controller.saveGoal(newGoal);
                if (!context.mounted) return;
                Navigator.pop(context, true);
              }
            },
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
      appBar: AppBar(
        title: Flexible(
          child: Text(
            AppLocalizations.of(context)!.savings_goals,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _goals.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.no_goals_yet))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final progress = (goal.savedAmount / goal.targetAmount).clamp(
                    0.0,
                    1.0,
                  );
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _addOrEditGoal(goal),
                                    icon: const Icon(Icons.edit, size: 20),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await _controller.deleteGoal(goal.id!);
                                      _loadGoals();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              '${CurrencyHelper.format(goal.savedAmount, context)} / ${CurrencyHelper.format(goal.targetAmount, context)}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditGoal(),
        label: Text(
          AppLocalizations.of(context)!.new_goal,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
