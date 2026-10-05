import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/app_button.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';
import '../router/navigation_service.dart';
import '../i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

class PremiumFlowService {
  /// Lo que incluye PRO (P-05). La pantalla Pro muestra lo mismo.
  static const List<String> proBenefitKeys = [
    'pro_benefit_stats',
    'pro_benefit_goals',
    'pro_benefit_vault',
    'pro_benefit_debt_tips',
  ];

  static void showUpgradePrompt(BuildContext context) {
    final l10n = context.read<AppLocaleController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              32,
              24,
              48,
            ), // Padding inferior generoso para ergonomía
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  AppIcons.pro,
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
                for (final key in proBenefitKeys) _buildBenefit(l10n.text(key)),
                const SizedBox(height: 32),
                AppButton(
                  onTap: () {
                    NavigationService.goBack();
                    NavigationService.navigate("/premium");
                  },
                  color: AppColors.gold,
                  label: l10n.text('try_premium'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => NavigationService.goBack(),
                  child: Text(
                    l10n.text('continue_free'),
                    style: AppTextStyles.bodyText,
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
          const Icon(AppIcons.done, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
