import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isSpanish = locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacy_policy), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSpanish
                  ? 'Tu Privacidad es Primero'
                  : 'Your Privacy Comes First',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              child: ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(
                    'https://example.com/privacy-policy',
                  ); // Replace with real URL
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  isSpanish
                      ? 'Ver política completa online'
                      : 'View full policy online',
                ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7E57C2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}
