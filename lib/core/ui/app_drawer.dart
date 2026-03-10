import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../../core/state/app_state.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import 'design/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isPro = AppState.instance.isPro;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPro
                    ? [const Color(0xFF6A5AE0), const Color(0xFF9F7AEA)]
                    : [AppColors.background, AppColors.cardBackground],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '\$imple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPro ? AppColors.neonCyan : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isPro)
                            BoxShadow(
                              color: AppColors.neonCyan.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPro ? 'PREMIUM' : 'FREE ACCOUNT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openDashboard);
                  },
                ),
                _DrawerItem(
                  icon: Icons.swap_vert_rounded,
                  title: 'Transacciones',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openMovements();
                  },
                ),
                _DrawerItem(
                  icon: Icons.analytics_rounded,
                  title: 'Estadísticas',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openStats);
                  },
                ),
                _DrawerItem(
                  icon: Icons.layers_rounded,
                  title: 'Categorías',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openCategories);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                if (isPro) ...[
                  Text(
                    'PRO FEATURES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DrawerItem(
                    icon: Icons.auto_graph_rounded,
                    title: 'Inteligencia AI',
                    onTap: () {
                      GeneralFlowService.goBack();
                      GeneralFlowService.openPrediction();
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lock_rounded,
                    title: 'Bóveda Segura',
                    onTap: () {
                      GeneralFlowService.goBack();
                      ActionController.execute(context, AppAction.openVault);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Configuraciones',
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
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
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
