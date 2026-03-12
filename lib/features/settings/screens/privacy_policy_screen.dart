import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/widgets/gradient_button.dart';

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
              isSpanish ? 'Almacenamiento Local' : 'Local Storage',
              isSpanish
                  ? '\$imple es una aplicación diseñada para funcionar de forma privada. Todos tus datos financieros (ingresos, gastos, metas y deudas) se almacenan exclusivamente de forma local en tu dispositivo.'
                  : '\$imple is designed to work privately. All your financial data (income, expenses, goals and debts) are stored locally on your device.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Seguridad de los Datos' : 'Data Security',
              isSpanish
                  ? 'No subimos tu información a servidores externos. Tu privacidad está garantizada ya que tú eres el único dueño de tus datos. Recomendamos realizar copias de seguridad manuales periódicamente.'
                  : 'We do not upload your information to external servers. Your privacy is guaranteed because you are the sole owner of your data. We recommend creating manual backups periodically.',
            ),
            _buildSection(
              context,
              isSpanish ? 'Terceros' : 'Third Parties',
              isSpanish
                  ? 'La aplicación no comparte ningún dato personal ni financiero con terceros. No rastreamos tu comportamiento fuera de la aplicación.'
                  : 'The application does not share any personal or financial data with third parties. We do not track your behavior outside the app.',
            ),
            const SizedBox(height: 32),
            Center(
              child: GradientButton(
                onPressed: () async {
                  final url = Uri.parse('https://example.com/privacy-policy');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                text: isSpanish
                    ? 'Ver política completa online'
                    : 'View full policy online',
              ),
            ),
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
