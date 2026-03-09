import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../../core/state/app_state.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import 'design/app_design.dart';
import 'design/pro_design.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isPro = AppState.instance.isPro;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPro
                    ? ProDesign.dashboardGradient
                    : AppDesign.dashboardGradient,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Control Financiero',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isPro ? 'Usuario PRO' : 'Plan Básico',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Inicio',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openDashboard);
                  },
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  title: 'Movimientos',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openMovements();
                  },
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  title: 'Análisis',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openStats);
                  },
                ),
                _DrawerItem(
                  icon: Icons.savings_outlined,
                  activeIcon: Icons.savings,
                  title: 'Deudas',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openDebts);
                  },
                ),
                if (isPro) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      'HERRAMIENTAS PRO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.auto_graph_outlined,
                    title: 'Predicción de gastos',
                    onTap: () {
                      GeneralFlowService.goBack();
                      GeneralFlowService.openPrediction();
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    title: 'Bóveda privada',
                    onTap: () {
                      GeneralFlowService.goBack();
                      ActionController.execute(context, AppAction.openVault);
                    },
                  ),
                ],
                const Divider(indent: 16, endIndent: 16, height: 32),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Ajustes',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openSettings);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    this.activeIcon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
