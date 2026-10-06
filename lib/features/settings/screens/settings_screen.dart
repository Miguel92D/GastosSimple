import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/widgets/pro_badge.dart';
import '../../../core/ui/widgets/app_list_row.dart';
import '../../../core/ui/widgets/app_section_title.dart';
import '../../../core/ui/widgets/app_sheet.dart';
import '../../../core/flow/general_flow_service.dart';

import '../../../services/security_service.dart';
import '../../../services/notification_service.dart';
import 'pin_screen.dart';
import '../../dev/design_catalog_screen.dart';
import '../../../services/currency_service.dart';
import '../../../services/dev_monthly_test_data_service.dart';
import '../../../services/purchase_service.dart';
import '../widgets/manage_purchase_button.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

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
    // Muestra "Cuenta Premium activa": se revisa que la compra siga vigente.
    PurchaseService.instance.refreshOwnershipIfPro();
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            children: [
              ..._section(l10n.text('language'), [
                _buildItem(
                  title: l10n.text('language'),
                  subtitle: l10n.locale == 'es'
                      ? l10n.text('language_es')
                      : l10n.text('language_en'),
                  leading: AppIcons.language,
                  onTap: () {
                    final newLocale = l10n.locale == 'es' ? 'en' : 'es';
                    l10n.changeLocale(newLocale);
                  },
                ),
              ]),

              ..._section(l10n.text('security'), [
                _buildSwitch(
                  title: l10n.text('enable_pin'),
                  subtitle: l10n.text('pin_subtitle'),
                  icon: AppIcons.pin,
                  value: securityService.isPinActive,
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
                    leading: AppIcons.edit,
                    onTap: () => _changePin(isVault: false),
                  ),
                _buildSwitch(
                  title: l10n.text('biometric_unlock'),
                  subtitle: l10n.text('biometric_subtitle'),
                  icon: AppIcons.fingerprint,
                  value: securityService.isBiometricActive,
                  onChanged: (val) async {
                    if (val) {
                      final canUse = await securityService.canUseBiometrics;
                      if (!context.mounted) return;
                      if (canUse) {
                        // Huella y PIN van por separado (D-035): el repuesto
                        // de la huella es el bloqueo del teléfono.
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

                const Divider(),

                _buildSwitch(
                  title: l10n.text('enable_vault_pin'),
                  subtitle: l10n.text('vault_pin_subtitle'),
                  icon: AppIcons.vault,
                  value: securityService.isVaultPinActive,
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
                    leading: AppIcons.edit,
                    onTap: () => _changePin(isVault: true),
                  ),
              ]),

              ..._section(l10n.text('reminder_section'), [
                _buildSwitch(
                  title: l10n.text('reminder_daily'),
                  subtitle: l10n.text('reminder_daily_subtitle'),
                  icon: AppIcons.reminder,
                  value: _reminderEnabled,
                  onChanged: (val) => _toggleReminder(val, l10n),
                ),
                if (_reminderEnabled)
                  _buildItem(
                    title: l10n.text('reminder_time'),
                    subtitle: _reminderTime.format(context),
                    leading: AppIcons.time,
                    onTap: _pickReminderTime,
                  ),
              ]),

              ..._section(l10n.text('backup_data_title'), [
                _buildItem(
                  title: l10n.text('local_backup_label'),
                  subtitle: l10n.text('backup_screen_desc'),
                  leading: AppIcons.backup,
                  onTap: () => Navigator.pushNamed(context, '/backup'),
                ),
              ]),

              ..._section(l10n.text('premium_account'), showBadge: true, [
                if (appState.isPro)
                  _buildItem(
                    title: l10n.text('premium_account_active'),
                    subtitle: l10n.text('premium_account_active_subtitle'),
                    leading: AppIcons.proActive,
                    trailing: const Icon(
                      AppIcons.done,
                      color: AppColors.incomeGreen,
                    ),
                    onTap: () {},
                  )
                else
                  _buildItem(
                    title: l10n.text('activate_pro'),
                    subtitle: l10n.text('premium_description'),
                    leading: AppIcons.pro,
                    onTap: () => Navigator.pushNamed(context, '/premium'),
                  ),
                _buildItem(
                  title: _isRestoringPurchase
                      ? l10n.text('premium_restore_loading')
                      : l10n.text('restore_purchase'),
                  subtitle: l10n.text('premium_restore_subtitle'),
                  leading: AppIcons.restore,
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
                // Ver la compra / pedir reembolso: solo con PRO (D-027).
                if (appState.isPro) const ManagePurchaseButton(),
              ]),

              ..._section(l10n.text('currency'), [
                _buildItem(
                  title: l10n.text('select_currency'),
                  subtitle:
                      '${currencyService.selectedCurrency.name} (${currencyService.currencySymbol})',
                  leading: AppIcons.currency,
                  onTap: () => _showCurrencySelector(context),
                ),
              ]),

              ..._section(l10n.text('legal'), [
                _buildItem(
                  title: l10n.text('privacy_policy'),
                  leading: AppIcons.privacy,
                  onTap: () => GeneralFlowService.openPrivacy(),
                ),
                _buildSwitch(
                  title: l10n.text('crash_reports_title'),
                  subtitle: l10n.text('crash_reports_subtitle'),
                  icon: AppIcons.crashReports,
                  value: appState.crashReportsEnabled,
                  onChanged: (val) => appState.setConsent(crashReports: val),
                ),
              ]),

              if (kDebugMode) ...[
                ..._section('DEV / TEST MENSUAL', [
                  _buildItem(
                    title: 'Cargar datos mensuales de prueba',
                    subtitle: 'Inserta datos TEST_MENSUAL_ en 3 meses',
                    leading: AppIcons.devTools,
                    onTap: _loadMonthlyTestData,
                  ),
                  _buildItem(
                    title: 'Catálogo de diseño',
                    subtitle: 'Todos los módulos juntos (D-032)',
                    leading: AppIcons.categories,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DesignCatalogScreen(),
                      ),
                    ),
                  ),
                  _buildItem(
                    title: 'Borrar datos mensuales de prueba',
                    subtitle: 'Borra solo notas TEST_MENSUAL_',
                    leading: AppIcons.deleteAll,
                    onTap: _deleteMonthlyTestData,
                  ),
                ]),
              ],

              const SizedBox(height: 60),
            ],
          ),
          if (_isLoading)
            Container(
              color: AppColors.overlay,
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

  /// Una sección de Ajustes: título y sus filas dentro de una tarjeta de
  /// vidrio, como el resto de la app (A-06, D-029).
  List<Widget> _section(
    String title,
    List<Widget> children, {
    bool showBadge = false,
  }) {
    return [
      _buildSectionTitle(title, showBadge: showBadge),
      GlassCard(
        borderRadius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Column(children: children),
      ),
      const SizedBox(height: AppSpacing.sm),
    ];
  }

  Widget _buildSectionTitle(String title, {bool showBadge = false}) {
    return AppSectionTitle(
      title,
      trailing: showBadge ? const ProBadge() : null,
    );
  }

  Widget _buildItem({
    required String title,
    String? subtitle,
    required IconData leading,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return AppListRow.setting(
      icon: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// Fila de Ajustes con interruptor: tocar la fila también lo cambia.
  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppListRow.setting(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
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

    AppSheet.show<void>(
      context,
      maxHeightFactor: 0.7,
      horizontalPadding: 0,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSheetTitle(l10n.text('select_currency')),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: CurrencyService.availableCurrencies.length,
                itemBuilder: (context, index) {
                  final c = CurrencyService.availableCurrencies[index];
                  final isSelected = currencyService.currencyCode == c.code;
                  return ListTile(
                    title: Text(
                      c.name,
                      style: AppTextStyles.bodyMain.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            AppIcons.done,
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
