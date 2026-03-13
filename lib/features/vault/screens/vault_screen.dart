import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/vault_dashboard.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_fab.dart';
import '../../../core/ui/app_drawer.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('secret_expenses'),
      drawer: const AppDrawer(),
      body: const VaultDashboard(),
      floatingActionButton: const AppFAB(mode: "vault"),
    );
  }
}
