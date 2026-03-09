import 'package:flutter/material.dart';
import '../widgets/vault_dashboard.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_fab.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: "Bóveda privada",
      body: VaultDashboard(),
      floatingActionButton: AppFAB(mode: "vault"),
    );
  }
}
