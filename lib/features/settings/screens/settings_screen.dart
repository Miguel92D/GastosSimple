import 'package:flutter/material.dart';
import '../../../services/language_service.dart';
import '../../../services/theme_service.dart';
import '../../../services/security_service.dart';
import '../../../services/pro_service.dart';
import '../../../services/cloud_backup_service.dart';
import '../../../services/currency_service.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.settings,
      drawer: const AppDrawer(),
      body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSectionTitle(l10n.language),
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
            _buildSectionTitle(l10n.dark_mode),
            ListenableBuilder(
              listenable: ThemeService.instance,
              builder: (context, _) => SwitchListTile(
                title: Text(
                  l10n.dark_mode,
                  style: AppTextStyles.bodyMain.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                secondary: Icon(
                  ThemeService.instance.themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: AppColors.primaryPurple,
                ),
                activeColor: AppColors.primaryPurple,
                value: ThemeService.instance.themeMode == ThemeMode.dark,
                onChanged: (val) => ThemeService.instance.toggleTheme(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle(l10n.security),
            ListenableBuilder(
              listenable: SecurityService.instance,
              builder: (context, _) => Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      l10n.enable_pin,
                      style: AppTextStyles.bodyMain.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.pin_subtitle,
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
                  SwitchListTile(
                    title: Text(
                      l10n.biometric_unlock,
                      style: AppTextStyles.bodyMain.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.biometric_subtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                    activeColor: AppColors.primaryPurple,
                    value: SecurityService.instance.isBiometricActive,
                    onChanged: (val) =>
                        SecurityService.instance.setBiometricActive(val),
                  ),
                  if (SecurityService.instance.hasPin)
                    _buildItem(
                      title: l10n.change_pin,
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
            _buildSectionTitle('CLOUD BACKUP (PRO)'),
            _buildItem(
              title: 'Backup Now',
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
                    const SnackBar(content: Text('Starting backup...')),
                  );
                  await CloudBackupService.instance.backupData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup successful!')),
                  );
                }
              },
            ),
            _buildItem(
              title: 'Restore Backup',
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
                    const SnackBar(content: Text('Restoring backup...')),
                  );
                  await CloudBackupService.instance.restoreData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore successful!')),
                  );
                }
              },
            ),
            SwitchListTile(
              title: Text(
                'Automatic Backup',
                style: AppTextStyles.bodyMain.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Backup after every new record',
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
            _buildSectionTitle(l10n.currency),
            ListenableBuilder(
              listenable: CurrencyService.instance,
              builder: (context, _) => _buildItem(
                leading: Icons.payments_rounded,
                title: l10n.currency,
                subtitle: CurrencyService.instance.currencySymbol,
                onTap: () => _showCurrencySelector(context),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: AppColors.cardBorder),
            ),
            _buildSectionTitle(l10n.legal),
            _buildItem(
              title: l10n.privacy_policy,
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
        color: AppColors.softText.withOpacity(0.7),
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: AppColors.primaryPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          AppLocalizations.of(context)!.set_pin,
          style: AppTextStyles.cardTitle,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.new_pin_label,
            labelStyle: TextStyle(color: AppColors.softText.withOpacity(0.5)),
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
              AppLocalizations.of(context)!.delete,
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
            child: const Text(
              'SAVE',
              style: TextStyle(
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
