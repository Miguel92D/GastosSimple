import 'package:flutter/material.dart';
import '../../dashboard/widgets/dashboard_widget.dart';

class VaultDashboard extends StatelessWidget {
  const VaultDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardWidget(isVault: true);
  }
}
