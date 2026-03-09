import 'package:flutter/material.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import 'quick_action_menu.dart';

class AppFAB extends StatelessWidget {
  final String mode; // "normal" o "vault"

  const AppFAB({super.key, this.mode = "normal"});

  @override
  Widget build(BuildContext context) {
    if (mode == "normal") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // INGRESO
          FloatingActionButton(
            heroTag: "income_btn",
            backgroundColor: Colors.green,
            elevation: 4,
            onPressed: () {
              ActionController.execute(context, AppAction.addIncome);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),

          const SizedBox(height: 12),

          // GASTO
          FloatingActionButton(
            heroTag: "expense_btn",
            backgroundColor: Colors.red,
            elevation: 4,
            onPressed: () {
              ActionController.execute(context, AppAction.addExpense);
            },
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ],
      );
    }

    return FloatingActionButton(
      onPressed: () {
        QuickActionMenu.open(context, mode: mode);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }
}
