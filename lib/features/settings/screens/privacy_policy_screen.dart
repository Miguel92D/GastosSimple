import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final locale = Localizations.localeOf(context);
    final isSpanish = locale.languageCode == 'es';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(l10n.text('privacy_policy')),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSpanish
                  ? 'Tu Privacidad es Primero'
                  : 'Your Privacy Comes First',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              isSpanish ? 'Datos en el dispositivo' : 'On-device data',
              isSpanish
                  ? '\$imple guarda tus datos financieros en tu dispositivo. Esto incluye ingresos, gastos, deudas, metas, presupuestos, categorias, notas y movimientos privados de la boveda.'
                  : '\$imple stores your financial data on your device. This includes income, expenses, debts, goals, budgets, categories, notes, and private vault movements.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Backups locales' : 'Local backups',
              isSpanish
                  ? 'La app permite exportar e importar un archivo JSON de respaldo. Ese archivo puede incluir tus datos financieros y de boveda. Cuando lo compartes o guardas, el destino que eliges queda bajo tu control.'
                  : 'The app lets you export and import a JSON backup file. That file can include your financial and vault data. When you share or save it, the destination you choose is under your control.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Compras PRO' : 'PRO purchases',
              isSpanish
                  ? 'La compra unica de PRO se procesa con Google Play Billing. La app usa el estado de compra y restauracion solo para activar o restaurar las funciones PRO.'
                  : 'The one-time PRO purchase is processed with Google Play Billing. The app uses purchase and restore status only to activate or restore PRO features.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Diagnosticos de fallos' : 'Crash diagnostics',
              isSpanish
                  ? 'Usamos Firebase Crashlytics para detectar fallos y mejorar la estabilidad. Crashlytics puede enviar a Firebase/Google reportes de errores, trazas, estado de la app, metadatos del dispositivo e identificadores de instalacion. No usamos Firebase Analytics.'
                  : 'We use Firebase Crashlytics to detect crashes and improve stability. Crashlytics may send error reports, stack traces, app state, device metadata, and installation identifiers to Firebase/Google. We do not use Firebase Analytics.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Seguridad local' : 'Local security',
              isSpanish
                  ? 'Puedes proteger la app y la boveda con PIN y biometria. Los PIN se guardan localmente mediante almacenamiento seguro. La biometria la procesa el sistema operativo; la app no recibe ni guarda plantillas biometricas.'
                  : 'You can protect the app and vault with PIN and biometrics. PINs are stored locally using secure storage. Biometrics are handled by the operating system; the app does not receive or store biometric templates.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Notificaciones' : 'Notifications',
              isSpanish
                  ? 'La app puede programar recordatorios locales para registrar tus movimientos. Puedes controlar los permisos de notificacion desde el sistema operativo.'
                  : 'The app may schedule local reminders to record your movements. You can control notification permissions from the operating system.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Sin cuentas ni nube' : 'No accounts or cloud sync',
              isSpanish
                  ? 'Esta version no ofrece cuenta, inicio de sesion, Google Sign-In, Firebase Auth, Firestore ni backup en la nube. Tus registros financieros no se suben a un servidor de \$imple.'
                  : 'This release does not offer accounts, sign-in, Google Sign-In, Firebase Auth, Firestore, or cloud backup. Your financial records are not uploaded to a \$imple server.',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri.parse('https://simple-app-ar.github.io/privacy.html');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primaryPurple.withValues(alpha: 0.4),
                ),
                child: Text(
                  isSpanish ? 'Ver política completa online' : 'View full policy online',
                  style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyText.copyWith(
              height: 1.5,
              color: AppColors.softText,
            ),
          ),
        ],
      ),
    );
  }
}
