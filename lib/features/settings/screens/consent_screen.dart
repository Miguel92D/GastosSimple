import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/router/navigation_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/widgets/gradient_button.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

/// Se muestra una sola vez (desde InitialGuard). Crashlytics arranca apagado
/// (ver AndroidManifest) y solo se activa si el usuario acepta.
class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.mainBackgroundRadial),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.privacy,
                size: 72,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.text('consent_title'),
                style: AppTextStyles.titleMain.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.text('consent_body'),
                style: AppTextStyles.bodyText.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: l10n.text('consent_accept'),
                  onPressed: () =>
                      AppState.instance.setConsent(crashReports: true),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    AppState.instance.setConsent(crashReports: false),
                child: Text(
                  l10n.text('consent_decline'),
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => NavigationService.navigate("/privacy"),
                child: Text(
                  l10n.text('consent_privacy'),
                  style: AppTextStyles.subtitle,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
