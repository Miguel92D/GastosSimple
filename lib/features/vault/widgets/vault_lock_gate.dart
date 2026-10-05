import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/router/navigation_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../services/security_service.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

/// Tapa las pantallas de la Bóveda cuando no se pueden ver: sin PRO, o con
/// PIN de Bóveda y la Bóveda cerrada (por ejemplo, al volver de segundo
/// plano la app cierra la Bóveda y lo secreto no queda a la vista).
class VaultLockGate extends StatelessWidget {
  final String title;
  final Widget child;

  const VaultLockGate({super.key, required this.title, required this.child});

  static bool canShow({
    required bool isPro,
    required bool vaultPinActive,
    required bool vaultUnlocked,
  }) {
    return isPro && (!vaultPinActive || vaultUnlocked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AppState.instance,
        SecurityService.instance,
      ]),
      builder: (context, _) {
        final isPro = AppState.instance.isPro;
        final security = SecurityService.instance;
        if (canShow(
          isPro: isPro,
          vaultPinActive: security.isVaultPinActive,
          vaultUnlocked: security.isVaultUnlocked,
        )) {
          return child;
        }
        return _LockedVault(title: title, needsPro: !isPro);
      },
    );
  }
}

class _LockedVault extends StatelessWidget {
  final String title;
  final bool needsPro;

  const _LockedVault({required this.title, required this.needsPro});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return AppScaffold(
      title: title,
      drawer: const AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.vault,
                size: 56,
                color: needsPro ? AppColors.gold : AppColors.primaryPurple,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.text('vault_locked_title'),
                style: AppTextStyles.titleMain,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.text(needsPro ? 'pro_benefit_vault' : 'vault_locked_body'),
                style: AppTextStyles.bodyText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.text(needsPro ? 'try_premium' : 'vault_open'),
                color: needsPro ? AppColors.gold : AppColors.primaryPurple,
                onTap: () => needsPro
                    ? NavigationService.navigate('/premium')
                    : ActionController.openVault(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
