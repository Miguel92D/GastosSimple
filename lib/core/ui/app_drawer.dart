import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../../core/state/app_state.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_text_styles.dart';
import 'widgets/gold_shimmer_text.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isPro = AppState.instance.isPro;

    return Drawer(
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              gradient: isPro
                  ? AppGradients.primaryGradient
                  : AppGradients.glassGradient,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.textPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                GoldShimmerText(text: '\$imple', isPro: isPro, fontSize: 28),
                Text(
                  'CONTROL FINANCIERO',
                  style: AppTextStyles.subLabel.copyWith(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPro
                            ? AppColors.incomeGreen
                            : AppColors.softText,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isPro)
                            BoxShadow(
                              color: AppColors.incomeGreen.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPro ? 'CUENTA PREMIUM' : 'CUENTA GRATIS',
                      style: AppTextStyles.subLabel.copyWith(
                        fontSize: 11,
                        color: AppColors.textPrimary.withOpacity(0.7),
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
                  icon: Icons.account_balance_rounded,
                  title: 'Deudas',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openDebts();
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Configuraciones',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openSettings();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Divider(color: AppColors.cardBorder, height: 1),
                ),
                if (isPro) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 12),
                    child: Text(
                      'PRO FEATURES',
                      style: AppTextStyles.subLabel.copyWith(
                        color: AppColors.softText.withOpacity(0.3),
                      ),
                    ),
                  ),
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
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: AppColors.softText.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMain.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
