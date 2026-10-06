import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/widgets/gradient_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  /// Secciones `privacy_s1`…`privacy_s8` de AppTranslations.
  static const int sectionCount = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('privacy_policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.text('privacy_heading'), style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.text('privacy_updated'), style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            // Mismo texto que privacy.html de la landing (Especificación §12).
            for (var i = 1; i <= sectionCount; i++)
              _buildSection(
                context,
                l10n.text('privacy_s${i}_title'),
                l10n.text('privacy_s${i}_body'),
              ),
            const SizedBox(height: 32),
            GradientButton(
              text: l10n.text('privacy_view_online'),
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://simple-app-ar.github.io/privacy.html',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
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
