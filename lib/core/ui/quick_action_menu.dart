import 'package:flutter/material.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';

class QuickActionMenu {
  static void open(BuildContext context, {String mode = "normal"}) {
    final bool isVault = mode == "vault";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  isVault
                      ? 'Registrar en Bóveda'
                      : '¿Qué quieres registrar hoy?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isVault) ...[
                ListTile(
                  leading: const Icon(Icons.flash_on, color: Colors.amber),
                  title: const Text('Entrada rápida'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/quick_entry");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.green),
                  title: const Text('Agregar ingreso'),
                  onTap: () {
                    Navigator.pop(context);
                    ActionController.execute(context, AppAction.addIncome);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.red),
                  title: const Text('Agregar gasto'),
                  onTap: () {
                    Navigator.pop(context);
                    ActionController.execute(context, AppAction.addExpense);
                  },
                ),
              ],
              ListTile(
                leading: Icon(
                  isVault ? Icons.arrow_upward : Icons.lock,
                  color: isVault ? Colors.green : Colors.amber,
                ),
                title: Text(
                  isVault
                      ? 'Agregar ingreso privado'
                      : 'Agregar movimiento privado',
                ),
                onTap: () {
                  Navigator.pop(context);
                  ActionController.openQuickEntryVault(context);
                },
              ),
              if (isVault)
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.red),
                  title: const Text('Agregar gasto privado'),
                  onTap: () {
                    Navigator.pop(context);
                    ActionController.openQuickEntryVault(context);
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
