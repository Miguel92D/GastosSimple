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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), elevation: 0),
      body: SafeArea(
        child: ListView(
          children: [
            _buildSectionTitle(l10n.language),
            ListTile(
              title: const Text('Español'),
              leading: const Icon(Icons.language),
              trailing: LanguageService.instance.locale.languageCode == 'es'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => LanguageService.instance.setLocale('es'),
            ),
            ListTile(
              title: const Text('English'),
              leading: const Icon(Icons.language),
              trailing: LanguageService.instance.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => LanguageService.instance.setLocale('en'),
            ),
            const Divider(),
            _buildSectionTitle(l10n.dark_mode),
            ListenableBuilder(
              listenable: ThemeService.instance,
              builder: (context, _) => SwitchListTile(
                title: Text(AppLocalizations.of(context)!.dark_mode),
                secondary: Icon(
                  ThemeService.instance.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                value: ThemeService.instance.themeMode == ThemeMode.dark,
                onChanged: (val) => ThemeService.instance.toggleTheme(),
              ),
            ),
            const Divider(),
            _buildSectionTitle(l10n.security),
            ListenableBuilder(
              listenable: SecurityService.instance,
              builder: (context, _) => Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.enable_pin),
                    subtitle: Text(l10n.pin_subtitle),
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
                    title: Text(l10n.biometric_unlock),
                    subtitle: Text(l10n.biometric_subtitle),
                    value: SecurityService.instance.isBiometricActive,
                    onChanged: (val) =>
                        SecurityService.instance.setBiometricActive(val),
                  ),
                  if (SecurityService.instance.hasPin)
                    ListTile(
                      title: Text(l10n.change_pin),
                      leading: const Icon(Icons.pin),
                      onTap: () => _showSetPinDialog(context),
                    ),
                ],
              ),
            ),
            const Divider(),
            _buildSectionTitle('Cloud Backup (PRO)'),
            ListTile(
              title: const Text('Backup Now'),
              leading: const Icon(Icons.cloud_upload),
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
            ListTile(
              title: const Text('Restore Backup'),
              leading: const Icon(Icons.cloud_download),
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
              title: const Text('Automatic Backup'),
              subtitle: const Text('Backup after every new record'),
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
            const Divider(),
            _buildSectionTitle(l10n.currency),
            ListenableBuilder(
              listenable: CurrencyService.instance,
              builder: (context, _) => ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(l10n.currency),
                subtitle: Text(CurrencyService.instance.currencySymbol),
                onTap: () => _showCurrencySelector(context),
              ),
            ),
            const Divider(),
            _buildSectionTitle(l10n.legal),
            ListTile(
              title: Text(l10n.privacy_policy),
              leading: const Icon(Icons.policy),
              onTap: () {
                GeneralFlowService.openPrivacy();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('\$ Peso'),
                onTap: () async {
                  await CurrencyService.instance.setCurrency('\$');
                  if (!context.mounted) return;
                  GeneralFlowService.goBack();
                },
              ),
              ListTile(
                title: const Text('USD Dollar'),
                onTap: () async {
                  await CurrencyService.instance.setCurrency('USD ');
                  if (!context.mounted) return;
                  GeneralFlowService.goBack();
                },
              ),
              ListTile(
                title: const Text('€ Euro'),
                onTap: () async {
                  await CurrencyService.instance.setCurrency('€');
                  if (!context.mounted) return;
                  GeneralFlowService.goBack();
                },
              ),
              ListTile(
                title: const Text('R\$ Real'),
                onTap: () async {
                  await CurrencyService.instance.setCurrency('R\$');
                  if (!context.mounted) return;
                  GeneralFlowService.goBack();
                },
              ),
              ListTile(
                title: const Text('¥ Yen'),
                onTap: () async {
                  await CurrencyService.instance.setCurrency('¥');
                  if (!context.mounted) return;
                  GeneralFlowService.goBack();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSetPinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.set_pin),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.new_pin_label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => GeneralFlowService.goBack(),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await SecurityService.instance.setPin(controller.text);
                await SecurityService.instance.setPinActive(true);
                if (context.mounted) GeneralFlowService.goBack();
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
}
