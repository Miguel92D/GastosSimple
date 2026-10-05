import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/vault_dashboard.dart';
import '../widgets/vault_lock_gate.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_fab.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/router/navigation_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return VaultLockGate(
      title: l10n.text('secret_expenses'),
      child: AppScaffold(
        title: l10n.text('secret_expenses'),
        drawer: const AppDrawer(),
        actions: [
          // Pagos fijos de la Bóveda (solo los secretos).
          IconButton(
            tooltip: l10n.text('recurring_title'),
            icon: const Icon(Icons.autorenew_rounded),
            onPressed: () => NavigationService.navigate(
              '/recurring',
              arguments: {'isVault': true},
            ),
          ),
        ],
        body: const VaultDashboard(),
        floatingActionButton: const AppFAB(mode: "vault"),
      ),
    );
  }
}
