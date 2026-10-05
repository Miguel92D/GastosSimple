import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/widgets/pro_badge.dart';
import '../../../core/flow/general_flow_service.dart';

import '../../../services/security_service.dart';
import '../../../services/notification_service.dart';
import 'pin_screen.dart';
import '../../../services/currency_service.dart';
import '../../../services/dev_monthly_test_data_service.dart';
import '../../../services/purchase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Pide el PIN actual antes de desactivarlo o cambiarlo. Sin esto,
  /// cualquiera con el teléfono podía apagar el PIN de la Bóveda desde
  /// Ajustes y entrar a ella.
  Future<bool> _confirmCurrentPin({required bool isVault}) async {
    final security = SecurityService.instance;
    final hasPin = isVault ? security.hasVaultPin : security.hasPin;
    if (!hasPin) return true;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PinScreen(isVault: isVault)),
    );
    return result == true;
  }

  Future<void> _changePin({required bool isVault}) async {
    if (!await _confirmCurrentPin(isVault: isVault)) return;
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      '/pin',
      arguments: {'setup': true, if (isVault) 'isVault': true},
    );
  }

  final bool _isLoading = false;
  bool _isRestoringPurchase = false;

  // Recordatorio diario
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: NotificationService.defaultHour,
    minute: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final s = await NotificationService.instance.getReminderSettings();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = s.enabled;
      _reminderTime = TimeOfDay(hour: s.hour, minute: s.minute);
    });
  }

  Future<void> _toggleReminder(bool value, AppLocaleController l10n) async {
    final ok = await NotificationService.instance.setReminderEnabled(value);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.text('reminder_permission_denied'))),
      );
      return;
    }
    setState(() => _reminderEnabled = value);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    await NotificationService.instance.setReminderTime(
      picked.hour,
      picked.minute,
    );
    if (!mounted) return;
    setState(() => _reminderTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final appState = context.watch<AppState>();
    final currencyService = context.watch<CurrencyService>();
    final securityService = context.watch<SecurityService>();

    // Mismo marco que el resto de la app (resplandor, título, flecha atrás).
    return AppScaffold(
      title: l10n.text('settings'),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // SECTION: LANGUAGE
              _buildSectionTitle(l10n.text('language')),
              _buildItem(
                title: l10n.text('language'),
                subtitle: l10n.locale == 'es'
                    ? l10n.text('language_es')
                    : l10n.text('language_en'),
                leading: Icons.language_rounded,
                onTap: () {
                  final newLocale = l10n.locale == 'es' ? 'en' : 'es';
                  l10n.changeLocale(newLocale);
                },
              ),

              const SizedBox(height: 16),
              _buildSectionTitle(l10n.text('security')),
              SwitchListTile(
                title: Text(
                  l10n.text('enable_pin'),
                  style: AppTextStyles.bodyMain,
                ),
                subtitle: Text(
                  l10n.text('pin_subtitle'),
                  style: AppTextStyles.bodySmall,
                ),
                secondary: Icon(
                  Icons.password_rounded,
                  color: AppColors.primaryPurple,
                ),
                value: securityService.isPinActive,
                activeThumbColor: AppColors.primaryPurple,
                onChanged: (val) async {
                  if (val) {
                    final result = await Navigator.pushNamed(
                      context,
                      '/pin',
                      arguments: {'setup': true},
                    );
                    if (result == true) {
                      await securityService.setPinActive(true);
                    }
                  } else if (await _confirmCurrentPin(isVault: false)) {
                    await securityService.setPinActive(false);
                  }
                },
              ),
              if (securityService.isPinActive)
                _buildItem(
                  title: l10n.text('change_pin'),
                  leading: Icons.edit_rounded,
                  onTap: () => _changePin(isVault: false),
                ),
              SwitchListTile(
                title: Text(
                  l10n.text('biometric_unlock'),
                  style: AppTextStyles.bodyMain,
                ),
                subtitle: Text(
                  l10n.text('biometric_subtitle'),
                  style: AppTextStyles.bodySmall,
                ),
                secondary: Icon(
                  Icons.fingerprint_rounded,
                  color: AppColors.primaryPurple,
                ),
                value: securityService.isBiometricActive,
                activeThumbColor: AppColors.primaryPurple,
                onChanged: (val) async {
                  if (val) {
                    final canUse = await securityService.canUseBiometrics;
                    if (!context.mounted) return;
                    if (canUse) {
                      // La huella necesita un PIN de repuesto: si todavía
                      // no hay, se crea primero.
                      if (!securityService.isPinActive ||
                          !securityService.hasPin) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.text('biometric_needs_pin')),
                          ),
                        );
                        final created = await Navigator.pushNamed(
                          context,
                          '/pin',
                          arguments: {'setup': true},
                        );
                        if (created != true) return;
                        await securityService.setPinActive(true);
                      }
                      await securityService.setBiometricActive(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.text('biometric_not_available')),
                        ),
                      );
                    }
                  } else {
                    await securityService.setBiometricActive(false);
                  }
                },
              ),

              const Divider(color: AppColors.cardBorder, height: 32),

              SwitchListTile(
                title: Text(
                  l10n.text('enable_vault_pin'),
                  style: AppTextStyles.bodyMain,
                ),
                subtitle: Text(
                  l10n.text('vault_pin_subtitle'),
                  style: AppTextStyles.bodySmall,
                ),
                secondary: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primaryPurple,
                ),
                value: securityService.isVaultPinActive,
                activeThumbColor: AppColors.primaryPurple,
                onChanged: (val) async {
                  if (val) {
                    final result = await Navigator.pushNamed(
                      context,
                      '/pin',
                      arguments: {'setup': true, 'isVault': true},
                    );
                    if (result == true) {
                      await securityService.setVaultPinActive(true);
                    }
                  } else if (await _confirmCurrentPin(isVault: true)) {
                    await securityService.setVaultPinActive(false);
                  }
                },
              ),
              if (securityService.isVaultPinActive)
                _buildItem(
                  title: l10n.text('change_pin'),
                  leading: Icons.edit_rounded,
                  onTap: () => _changePin(isVault: true),
                ),

              const SizedBox(height: 16),
              _buildSectionTitle(l10n.text('reminder_section')),
              SwitchListTile(
                title: Text(
                  l10n.text('reminder_daily'),
                  style: AppTextStyles.bodyMain,
                ),
                subtitle: Text(
                  l10n.text('reminder_daily_subtitle'),
                  style: AppTextStyles.bodySmall,
                ),
                secondary: Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primaryPurple,
                ),
                value: _reminderEnabled,
                activeThumbColor: AppColors.primaryPurple,
                onChanged: (val) => _toggleReminder(val, l10n),
              ),
              if (_reminderEnabled)
                _buildItem(
                  title: l10n.text('reminder_time'),
                  subtitle: _reminderTime.format(context),
                  leading: Icons.schedule_rounded,
                  onTap: _pickReminderTime,
                ),

              const SizedBox(height: 16),
              _buildSectionTitle(l10n.text('backup_data_title')),
              _buildItem(
                title: l10n.text('local_backup_label'),
                subtitle: l10n.text('backup_screen_desc'),
                leading: Icons.file_present_rounded,
                onTap: () => Navigator.pushNamed(context, '/backup'),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle(l10n.text('premium_account'), showBadge: true),
              if (appState.isPro)
                _buildItem(
                  title: l10n.text('premium_account_active'),
                  subtitle: l10n.text('premium_account_active_subtitle'),
                  leading: Icons.verified_rounded,
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.incomeGreen,
                  ),
                  onTap: () {},
                )
              else
                _buildItem(
                  title: l10n.text('activate_pro'),
                  subtitle: l10n.text('premium_description'),
                  leading: Icons.workspace_premium_rounded,
                  onTap: () => Navigator.pushNamed(context, '/premium'),
                ),
              _buildItem(
                title: _isRestoringPurchase
                    ? l10n.text('premium_restore_loading')
                    : l10n.text('restore_purchase'),
                subtitle: l10n.text('premium_restore_subtitle'),
                leading: Icons.restore_rounded,
                trailing: _isRestoringPurchase
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryPurple,
                        ),
                      )
                    : null,
                onTap: () {
                  _restorePurchase();
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.text('premium_google_play_manage_note'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softText.withAlpha(165),
                  ),
                ),
              ),

              _buildSectionTitle(l10n.text('currency')),
              _buildItem(
                title: l10n.text('select_currency'),
                subtitle:
                    '${currencyService.selectedCurrency.name} (${currencyService.currencySymbol})',
                leading: Icons.monetization_on_rounded,
                onTap: () => _showCurrencySelector(context),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle(l10n.text('legal')),
              _buildItem(
                title: l10n.text('privacy_policy'),
                leading: Icons.shield_outlined,
                onTap: () => GeneralFlowService.openPrivacy(),
              ),
              SwitchListTile(
                title: Text(
                  l10n.text('crash_reports_title'),
                  style: AppTextStyles.bodyMain,
                ),
                subtitle: Text(
                  l10n.text('crash_reports_subtitle'),
                  style: AppTextStyles.bodySmall,
                ),
                secondary: Icon(
                  Icons.bug_report_outlined,
                  color: AppColors.primaryPurple,
                ),
                value: appState.crashReportsEnabled,
                activeThumbColor: AppColors.primaryPurple,
                onChanged: (val) => appState.setConsent(crashReports: val),
              ),

              if (kDebugMode) ...[
                const Divider(color: AppColors.cardBorder, height: 32),
                _buildSectionTitle('DEV / TEST MENSUAL'),
                _buildItem(
                  title: 'Cargar datos mensuales de prueba',
                  subtitle: 'Inserta datos TEST_MENSUAL_ en 3 meses',
                  leading: Icons.science_rounded,
                  onTap: _loadMonthlyTestData,
                ),
                _buildItem(
                  title: 'Borrar datos mensuales de prueba',
                  subtitle: 'Borra solo notas TEST_MENSUAL_',
                  leading: Icons.delete_sweep_rounded,
                  onTap: _deleteMonthlyTestData,
                ),
              ],

              const SizedBox(height: 60),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showBadge = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryPurple,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showBadge) ...[const SizedBox(width: 8), const ProBadge()],
        ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        leading,
        color: AppColors.softText.withAlpha(180),
        size: 24,
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
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.softText.withAlpha(75),
          ),
      onTap: onTap,
    );
  }

  Future<void> _restorePurchase() async {
    if (_isRestoringPurchase) return;

    final l10n = context.read<AppLocaleController>();
    final service = PurchaseService.instance;

    setState(() => _isRestoringPurchase = true);
    try {
      await service.init();
      // Espera la respuesta de Google Play (o el tiempo máximo).
      final restored = await service.restorePurchases();
      if (!mounted) return;

      final hasError = !restored && service.errorMessage != null;
      final message = hasError
          ? l10n.text('premium_restore_failed')
          : restored
          ? l10n.text('premium_restore_success')
          : l10n.text('premium_restore_not_found');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: hasError
              ? AppColors.expenseRed
              : AppColors.primaryPurple,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.text('premium_restore_failed')),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoringPurchase = false);
      }
    }
  }

  void _showCurrencySelector(BuildContext context) {
    final l10n = context.read<AppLocaleController>();
    final currencyService = context.read<CurrencyService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                    style: AppTextStyles.titleMain,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: CurrencyService.availableCurrencies.length,
                    padding: const EdgeInsets.only(
                      bottom: 32,
                    ), // Padding para ergonomía
                    itemBuilder: (context, index) {
                      final c = CurrencyService.availableCurrencies[index];
                      final isSelected = currencyService.currencyCode == c.code;
                      return ListTile(
                        title: Text(
                          c.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryPurple,
                              )
                            : null,
                        onTap: () {
                          currencyService.setCurrency(c.symbol, c.code);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadMonthlyTestData() async {
    try {
      final result = await DevMonthlyTestDataService.loadMonthlyTestData();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Datos cargados: ${result.inserted}. Test previos borrados: ${result.deleted}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar datos de prueba: $e')),
      );
    }
  }

  Future<void> _deleteMonthlyTestData() async {
    try {
      final deleted = await DevMonthlyTestDataService.deleteMonthlyTestData();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos TEST_MENSUAL_ borrados: $deleted.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron borrar datos de prueba: $e')),
      );
    }
  }
}
