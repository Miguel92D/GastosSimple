import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../services/security_service.dart';
import '../../../services/pro_service.dart';
import '../../../services/cloud_backup_service.dart';
import '../../../services/currency_service.dart';
import '../controllers/settings_controller.dart';
import 'package:gastos_simple/features/settings/screens/pin_screen.dart';
import '../../../core/ui/widgets/pro_badge.dart';

import '../../../core/flow/general_flow_service.dart';
import '../../../core/flow/premium_flow_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../../../core/state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoBackup = false;

  @override
  void initState() {
    super.initState();
    _loadBackupState();
  }

  Future<void> _loadBackupState() async {
    final enabled = await CloudBackupService.instance.isAutoBackupEnabled();
    if (mounted) {
      setState(() => _autoBackup = enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('settings'),
      drawer: const AppDrawer(),
      body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSectionTitle(l10n.text('language')),
            _buildItem(
              title: l10n.text('language_es'),
              leading: Icons.language_rounded,
              trailing: l10n.locale == 'es'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () => SettingsController.changeLanguage('es'),
            ),
            _buildItem(
              title: l10n.text('language_en'),
              leading: Icons.language_rounded,
              trailing: l10n.locale == 'en'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () => SettingsController.changeLanguage('en'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle(l10n.text('security')),
            ListenableBuilder(
              listenable: SecurityService.instance,
              builder: (context, _) => Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      l10n.text('enable_pin'),
                      style: AppTextStyles.bodyMain.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.text('pin_subtitle'),
                      style: AppTextStyles.bodySmall,
                    ),
                    activeThumbColor: AppColors.primaryPurple,
                    value: SecurityService.instance.isPinActive,
                    onChanged: (val) async {
                      if (val && !SecurityService.instance.hasPin) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PinScreen(
                              isVault: false,
                              isSetup: true,
                            ),
                          ),
                        );
                        if (result == true) {
                          await SecurityService.instance.setPinActive(true);
                        }
                      } else {
                        await SecurityService.instance.setPinActive(val);
                      }
                    },
                  ),
                  if (SecurityService.instance.isPinActive)
                    _buildItem(
                      title: l10n.text('change_pin'),
                      leading: Icons.vpn_key_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinScreen(
                            isVault: false,
                            isSetup: true,
                          ),
                        ),
                      ),
                    ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  SwitchListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.text('enable_vault_pin'),
                          style: AppTextStyles.bodyMain.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const ProBadge(fontSize: 8, padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1)),
                      ],
                    ),
                    subtitle: Text(
                      l10n.text('vault_pin_subtitle'),
                      style: AppTextStyles.bodySmall,
                    ),
                    activeThumbColor: AppColors.primaryPurple,
                    value: SecurityService.instance.isVaultPinActive,
                    onChanged: (val) async {
                      if (val && !SecurityService.instance.hasVaultPin) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PinScreen(
                              isVault: true,
                              isSetup: true,
                            ),
                          ),
                        );
                        if (result == true) {
                          await SecurityService.instance.setVaultPinActive(true);
                        }
                      } else {
                        await SecurityService.instance.setVaultPinActive(val);
                      }
                    },
                  ),
                  if (SecurityService.instance.isVaultPinActive)
                    _buildItem(
                      title: l10n.text('change_pin') + " (${l10n.text('vault_label')})",
                      leading: Icons.enhanced_encryption_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinScreen(
                            isVault: true,
                            isSetup: true,
                          ),
                        ),
                      ),
                    ),
                  SwitchListTile(
                    title: Text(
                      l10n.text('biometric_unlock'),
                      style: AppTextStyles.bodyMain.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.text('biometric_subtitle'),
                      style: AppTextStyles.bodySmall,
                    ),
                    activeThumbColor: AppColors.primaryPurple,
                    value: SecurityService.instance.isBiometricActive,
                    onChanged: (val) =>
                        SecurityService.instance.setBiometricActive(val),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle(l10n.text('cloud_backup_title')),
            _buildItem(
              title: l10n.text('backup_now_label'),
              leading: Icons.cloud_upload_rounded,
              trailing: const ProBadge(),
              onTap: () async {
                if (!ProService.instance.isPro) {
                  PremiumFlowService.showUpgradePrompt(context);
                  return;
                }

                final user = await CloudBackupService.instance
                    .signInWithGoogle();
                if (!context.mounted) return;
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.text('starting_backup_msg'))),
                  );
                  await CloudBackupService.instance.backupData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.text('backup_success_msg'))),
                  );
                }
              },
            ),
            _buildItem(
              title: l10n.text('restore_backup_label'),
              leading: Icons.cloud_download_rounded,
              trailing: const ProBadge(),
              onTap: () async {
                if (!ProService.instance.isPro) {
                  PremiumFlowService.showUpgradePrompt(context);
                  return;
                }

                final user = await CloudBackupService.instance
                    .signInWithGoogle();
                if (!context.mounted) return;
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.text('restoring_backup_msg'))),
                  );
                  await CloudBackupService.instance.restoreData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.text('restore_success_msg'))),
                  );
                }
              },
            ),
            SwitchListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.text('auto_backup_label'),
                    style: AppTextStyles.bodyMain.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ProBadge(fontSize: 8, padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1)),
                ],
              ),
              subtitle: Text(
                l10n.text('auto_backup_desc'),
                style: AppTextStyles.bodySmall,
              ),
              activeThumbColor: AppColors.primaryPurple,
              value: _autoBackup,
              onChanged: (val) async {
                if (!ProService.instance.isPro) {
                  PremiumFlowService.showUpgradePrompt(context);
                  return;
                }

                if (val) {
                  final user = await CloudBackupService.instance
                      .signInWithGoogle();
                  if (user == null) return;
                }

                await CloudBackupService.instance.setAutoBackupEnabled(val);
                setState(() => _autoBackup = val);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle(l10n.text('currency')),
            ListenableBuilder(
              listenable: CurrencyService.instance,
              builder: (context, _) => _buildItem(
                leading: Icons.payments_rounded,
                title: l10n.text('currency'),
                subtitle: CurrencyService.instance.currencySymbol,
                onTap: () => _showCurrencySelector(context),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle(l10n.text('legal')),
            _buildItem(
              title: l10n.text('privacy_policy'),
              leading: Icons.shield_rounded,
              onTap: () {
                GeneralFlowService.openPrivacy();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle('💻 DEMO / TESTING'),
            SwitchListTile(
              title: const Text(
                'Activar Premium (Beta)',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Alternar entre cuenta Gratuita y Premium para probar funciones.',
                style: AppTextStyles.bodySmall,
              ),
              activeColor: AppColors.primaryPurple,
              value: ProService.instance.isPro,
              onChanged: (val) {
                if (val) {
                  ProService.instance.activatePro();
                  AppState.instance.setPro(true);
                } else {
                  ProService.instance.deactivatePro();
                  AppState.instance.setPro(false);
                }
                setState(() {});
              },
            ),
          ],
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.subLabel.copyWith(
          color: AppColors.primaryPurple,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildItem({
    required String title,
    String? subtitle,
    required IconData leading,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(
        leading,
        color: AppColors.softText.withValues(alpha: 0.7),
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.cardBorder),
      onTap: onTap,
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final l10n = context.read<AppLocaleController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.text('select_currency'),
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ...CurrencyService.availableCurrencies.map((c) => _buildCurrencyTile(
                          context,
                          c.name,
                          c.symbol,
                          c.code,
                        )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildCurrencyTile(
      BuildContext context, String title, String symbol, String code) {
    final isSelected = CurrencyService.instance.currencySymbol == symbol &&
        CurrencyService.instance.currencyCode == code;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withValues(alpha: 0.15)
              : AppColors.glassSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          symbol,
          style: AppTextStyles.bodyMain.copyWith(
            color: isSelected ? AppColors.primaryPurple : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMain.copyWith(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.primaryPurple)
          : null,
      onTap: () async {
        await CurrencyService.instance.setCurrency(symbol, code);
        if (!context.mounted) return;
        Navigator.pop(context);
      },
    );
  }
}
