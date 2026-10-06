import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../flow/premium_flow_service.dart';
import '../../i18n/app_locale_controller.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import 'app_icon_box.dart';

/// Los beneficios Pro, iguales en la pantalla Pro y en el aviso Pro (D-032).
/// Qué se promete sale de `PremiumFlowService.proBenefitKeys` (D-019).
class ProBenefitList extends StatelessWidget {
  const ProBenefitList({super.key});

  static const Map<String, IconData> _icons = {
    'pro_benefit_stats': AppIcons.stats,
    'pro_benefit_goals': AppIcons.goals,
    'pro_benefit_vault': AppIcons.vault,
    'pro_benefit_debt_tips': AppIcons.exitTips,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final key in PremiumFlowService.proBenefitKeys)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                AppIconBox(
                  icon: _icons[key] ?? AppIcons.pro,
                  color: AppColors.primaryPurple,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(l10n.text(key), style: AppTextStyles.rowTitle),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
