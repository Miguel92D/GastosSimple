import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/vault_dashboard.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_fab.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../services/security_service.dart';
import '../../settings/screens/pin_lock_screen.dart';


class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    final security = SecurityService.instance;
    final l10n = context.watch<AppLocaleController>();

    if (security.isPinActive && !security.isUnlocked) {
      return PinLockScreen(
        nextScreen: const VaultScreen(),
      );
    }

    return AppScaffold(
      title: l10n.text('secret_expenses'),
      drawer: const AppDrawer(),
      body: const VaultDashboard(),
      floatingActionButton: const AppFAB(mode: "vault"),
    );
  }
}
