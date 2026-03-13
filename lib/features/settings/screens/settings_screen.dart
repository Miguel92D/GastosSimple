import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../services/language_service.dart';
import '../../../services/security_service.dart';
import '../../../services/pro_service.dart';
import '../../../services/cloud_backup_service.dart';
import '../../../services/currency_service.dart';

import '../../../core/flow/general_flow_service.dart';
import '../../../core/flow/premium_flow_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

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
              title: 'Español',
              leading: Icons.language_rounded,
              trailing: LanguageService.instance.locale.languageCode == 'es'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () => LanguageService.instance.setLocale('es'),
            ),
            _buildItem(
              title: 'English',
              leading: Icons.language_rounded,
              trailing: LanguageService.instance.locale.languageCode == 'en'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () => LanguageService.instance.setLocale('en'),
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
                    activeColor: AppColors.primaryPurple,
                    value: SecurityService.instance.isPinActive,
                    onChanged: (val) async {
                      if (val && !SecurityService.instance.hasPin) {
                        _showSetPinDialog(context);
                      } else {
                        SecurityService.instance.setPinActive(val);
                      }
                    },
                  ),
                  if (SecurityService.instance.isPinActive)
                    SwitchListTile(
                      title: Text(
                        l10n.text('vault_only_pin'),
                        style: AppTextStyles.bodyMain.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.text('vault_only_pin_desc'),
                        style: AppTextStyles.bodySmall,
                      ),
                      activeColor: AppColors.primaryPurple,
                      value: SecurityService.instance.isVaultOnly,
                      onChanged: (val) =>
                          SecurityService.instance.setVaultOnly(val),
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
                    activeColor: AppColors.primaryPurple,
                    value: SecurityService.instance.isBiometricActive,
                    onChanged: (val) =>
                        SecurityService.instance.setBiometricActive(val),
                  ),
                  if (SecurityService.instance.hasPin)
                    _buildItem(
                      title: l10n.text('change_pin'),
                      leading: Icons.vpn_key_rounded,
                      onTap: () => _showSetPinDialog(context),
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
              title: Text(
                l10n.text('auto_backup_label'),
                style: AppTextStyles.bodyMain.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                l10n.text('auto_backup_desc'),
                style: AppTextStyles.bodySmall,
              ),
              activeColor: AppColors.primaryPurple,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GlassCard(
          borderRadius: 30,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCurrencyItem(context, '\$ Peso', '\$'),
              _buildCurrencyItem(context, 'USD Dollar', 'USD '),
              _buildCurrencyItem(context, '€ Euro', '€'),
              _buildCurrencyItem(context, 'R\$ Real', 'R\$'),
              _buildCurrencyItem(context, '¥ Yen', '¥'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyItem(BuildContext context, String title, String code) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.w700),
      ),
      onTap: () async {
        await CurrencyService.instance.setCurrency(code);
        if (!context.mounted) return;
        GeneralFlowService.goBack();
      },
    );
  }

  void _showSetPinDialog(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: AppColors.primaryPurple.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          context.watch<AppLocaleController>().text('set_pin'),
          style: AppTextStyles.cardTitle,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: context.watch<AppLocaleController>().text('new_pin_label'),
            labelStyle: TextStyle(color: AppColors.softText.withValues(alpha: 0.5)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryPurple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => GeneralFlowService.goBack(),
            child: Text(
              context.watch<AppLocaleController>().text('delete'),
              style: const TextStyle(color: AppColors.softText),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await SecurityService.instance.setPin(controller.text);
                await SecurityService.instance.setPinActive(true);
                if (context.mounted) GeneralFlowService.goBack();
              }
            },
            child: Text(
              l10n.text('save').toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
