import 'package:flutter/material.dart';
import '../i18n/app_locale_controller.dart';
import '../state/app_state.dart';
import '../../services/pro_service.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';
import 'package:provider/provider.dart';

class ProFeature extends StatelessWidget {
  final Widget child;

  const ProFeature({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isPro = AppState.instance.isPro || ProService.instance.isPro;
    final l10n = context.watch<AppLocaleController>();

    if (isPro) {
      return child;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 72, color: AppColors.gold),
          const SizedBox(height: 24),
          Text(
            l10n.text('premium_feature_title'),
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.text('premium_feature_desc'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/premium'),
            style: ElevatedButton.styleFrom(
              // Dorado = Pro. Texto oscuro: blanco sobre dorado no se lee.
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
            child: Text(
              l10n.text('view_plans_button').toUpperCase(),
              style: AppTextStyles.buttonLabel.copyWith(color: AppColors.darkBackground),
            ),
          ),
        ],
      ),
    );
  }
}
