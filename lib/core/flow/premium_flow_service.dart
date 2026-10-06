import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/app_button.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';
import '../router/navigation_service.dart';
import '../i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import '../ui/app_spacing.dart';
import '../ui/widgets/app_sheet.dart';
import '../ui/widgets/pro_benefit_list.dart';

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

    AppSheet.show<void>(
      context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                AppIcons.pro,
                size: AppIconSize.empty,
                color: AppColors.gold,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.text('unlock_premium_title'),
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              const ProBenefitList(),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                onTap: () {
                  NavigationService.goBack();
                  NavigationService.navigate("/premium");
                },
                color: AppColors.gold,
                label: l10n.text('try_premium'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => NavigationService.goBack(),
                child: Text(
                  l10n.text('continue_free'),
                  style: AppTextStyles.bodyText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
