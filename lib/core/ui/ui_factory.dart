import 'package:flutter/material.dart';
import '../state/app_mode_controller.dart';
import '../../features/dashboard/widgets/dashboard_card.dart';
import '../../features/vault/widgets/vault_card.dart';

class UIFactory {
  static Widget dashboardCard({required Widget child, bool isVault = false}) {
    if (isVault || AppModeController.instance.isVault) {
      return VaultCard(child: child);
    }
    return DashboardCard(child: child);
  }
}
