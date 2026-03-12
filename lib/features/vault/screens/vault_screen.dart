import 'package:flutter/material.dart';
import '../widgets/vault_dashboard.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_fab.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../services/security_service.dart';
import '../../settings/screens/pin_lock_screen.dart';
import '../../../l10n/app_localizations.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    final security = SecurityService.instance;
    final l10n = AppLocalizations.of(context)!;

    if (security.isPinActive && !security.isUnlocked) {
      return PinLockScreen(
        nextScreen: const VaultScreen(),
      );
    }

    return AppScaffold(
      title: l10n.secret_expenses,
      drawer: const AppDrawer(),
      body: const VaultDashboard(),
      floatingActionButton: const AppFAB(mode: "vault"),
    );
  }
}
