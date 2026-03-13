import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../services/purchase_service.dart';
import '../../../services/premium_service.dart';
import '../../../services/pro_service.dart';

import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/widgets/gradient_button.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = true;
  String _selectedProductId = 'simple_pro_annual';

  @override
  void initState() {
    super.initState();
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _restorePurchase() {
    PurchaseService.instance.restorePurchases();
  }

  Future<void> _buyPremium() async {
    final products = PurchaseService.instance.products;
    final product = products.cast<ProductDetails?>().firstWhere(
      (p) => p?.id == _selectedProductId,
      orElse: () => null,
    );

    if (product != null) {
      PurchaseService.instance.buyProduct(product);
    } else {
      await PremiumService.instance.setPremium(true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.watch<AppLocaleController>().text('premium_test_unlocked')),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: l10n.text('simple_pro'),
      drawer: const AppDrawer(),
      body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          size: 80,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.text('simple_pro'),
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.text('unlock_advanced_tools'),
                        style: AppTextStyles.bodyMain.copyWith(
                          color: AppColors.softText.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      _buildFeature(
                        Icons.psychology_rounded,
                        l10n.text('benefit_strategies'),
                      ),
                      _buildFeature(
                        Icons.auto_graph_rounded,
                        l10n.text('benefit_predictions'),
                      ),
                      _buildFeature(
                        Icons.analytics_rounded,
                        l10n.text('benefit_analytics'),
                      ),
                      _buildFeature(
                        Icons.lightbulb_outline_rounded,
                        l10n.text('smart_insights'),
                      ),
                      const SizedBox(height: 48),
                      if (!ProService.instance.isPro) ...[
                        _buildPlanCard(
                          l10n.text('monthly_plan'),
                          l10n.text('monthly_price'),
                          'simple_pro_monthly',
                        ),
                        const SizedBox(height: 16),
                        _buildPlanCard(
                          l10n.text('annual_plan'),
                          l10n.text('annual_price'),
                          'simple_pro_annual',
                          isRecommended: true,
                        ),
                        const SizedBox(height: 16),
                        _buildPlanCard(
                          l10n.text('lifetime_plan'),
                          l10n.text('lifetime_price'),
                          'simple_pro_lifetime',
                        ),
                        const SizedBox(height: 40),
                        GradientButton(
                          text: l10n.text('activate_pro').toUpperCase(),
                          onPressed: _buyPremium,
                          borderRadius: 24,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _restorePurchase,
                          child: Text(
                            l10n.text('restore_purchase'),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.softText.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ] else
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 24,
                          ),
                          borderRadius: 30,
                          glowColor: AppColors.incomeGreen.withValues(alpha: 0.1),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.incomeGreen,
                                size: 56,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.text('pro_active'),
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 22,
                                  color: AppColors.incomeGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPlanCard(String title, String price, String productId, {bool isRecommended = false}) {
    final selected = _selectedProductId == productId;
    final l10n = context.watch<AppLocaleController>();
    
    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = productId),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            borderRadius: 24,
            glowColor: selected ? AppColors.primaryPurple : Colors.transparent,
            borderWidth: selected ? 2 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                        color: selected ? AppColors.textPrimary : AppColors.softText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: selected ? AppColors.textPrimary.withValues(alpha: 0.7) : AppColors.softText.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                Radio<String>(
                  value: productId,
                  groupValue: _selectedProductId,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProductId = val);
                  },
                  activeColor: AppColors.primaryPurple,
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  l10n.text('best_value').toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMain.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
