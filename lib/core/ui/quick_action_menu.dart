import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
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
                    GeneralFlowService.goBack();
                    GeneralFlowService.openEntry();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.green),
                  title: const Text('Agregar ingreso'),
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.addIncome);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.red),
                  title: const Text('Agregar gasto'),
                  onTap: () {
                    GeneralFlowService.goBack();
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
                  GeneralFlowService.goBack();
                  ActionController.openQuickEntryVault(context);
                },
              ),
              if (isVault)
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.red),
                  title: const Text('Agregar gasto privado'),
                  onTap: () {
                    GeneralFlowService.goBack();
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
