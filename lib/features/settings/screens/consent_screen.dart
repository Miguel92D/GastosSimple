import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/router/navigation_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/widgets/gradient_button.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pantalla completa sin AppBar: mismo fondo que AppScaffold.
    return Container(
      decoration: BoxDecoration(gradient: AppGradients.mainBackgroundRadial),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Tu Privacidad',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '\$imple guarda tus datos financieros localmente en tu dispositivo para ayudarte a gestionar tu dinero.',
                style: AppTextStyles.bodyMain.copyWith(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'ACEPTAR',
                  borderRadius: AppRadius.lg,
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_consented', true);
                    if (context.mounted) {
                      NavigationService.navigateAndRemoveUntil("/dashboard");
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  NavigationService.navigate("/privacy");
                },
                child: Text(
                  'Ver política de privacidad',
                  style: AppTextStyles.bodyMain.copyWith(
                    color: AppColors.softText,
                  ),
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
