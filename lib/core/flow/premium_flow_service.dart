import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../router/navigation_service.dart';
import '../i18n/app_locale_controller.dart';

class PremiumFlowService {
  static void showUpgradePrompt(BuildContext context) {
    final l10n = context.read<AppLocaleController>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.text('unlock_premium_title'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.text('try_premium'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => NavigationService.goBack(),
                  child: Text(
                    l10n.text('continue_free'),
                    style: const TextStyle(color: Colors.grey),
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
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
