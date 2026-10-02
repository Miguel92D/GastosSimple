import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../router/navigation_service.dart';
import '../i18n/app_locale_controller.dart';
import '../ui/app_colors.dart';
import '../ui/app_radius.dart';
import '../ui/app_text_styles.dart';

class PremiumFlowService {
  static void showUpgradePrompt(BuildContext context) {
    final l10n = context.read<AppLocaleController>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.text('unlock_premium_title'),
                  style: AppTextStyles.titleMain.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildBenefit(l10n.text('feature_stats')),
                _buildBenefit(l10n.text('feature_monthly_analysis')),
                _buildBenefit(l10n.text('feature_budgets')),
                _buildBenefit(l10n.text('feature_goals')),

                _buildBenefit(l10n.text('feature_export')),
                _buildBenefit(l10n.text('feature_vault')),


                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    NavigationService.goBack();
                    NavigationService.navigate("/premium");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    // Dorado = Pro. Texto oscuro: blanco sobre dorado no se lee.
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    l10n.text('try_premium').toUpperCase(),
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.darkBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => NavigationService.goBack(),
                  child: Text(
                    l10n.text('continue_free'),
                    style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.incomeGreen),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.bodyMain.copyWith(fontSize: 16, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
