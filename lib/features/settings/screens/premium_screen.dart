import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/state/app_state.dart';
import '../../../services/purchase_service.dart';

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
  bool _isBuying = false;
  bool _isRestoring = false;
  String _selectedProductId = 'simple_pro_lifetime';

  @override
  void initState() {
    super.initState();
    PurchaseService.instance.addListener(_onPurchaseServiceChanged);
    _initStoreInfo();
  }

  @override
  void dispose() {
    PurchaseService.instance.removeListener(_onPurchaseServiceChanged);
    super.dispose();
  }

  void _onPurchaseServiceChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initStoreInfo() async {
    await PurchaseService.instance.init();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restorePurchase() async {
    final service = PurchaseService.instance;
    if (_isRestoring || service.purchaseInProgress || service.purchasePending) {
      _showBillingMessage();
      return;
    }
    setState(() => _isRestoring = true);
    await service.restorePurchases();
    if (mounted) {
      setState(() => _isRestoring = false);
      _showBillingMessage();
    }
  }

  Future<void> _buyPremium() async {
    final service = PurchaseService.instance;
    if (_isBuying || service.purchaseInProgress || service.purchasePending) {
      _showBillingMessage();
      return;
    }
    if (!service.initialized ||
        !service.available ||
        service.isLoadingProducts) {
      _showBillingMessage();
      return;
    }

    final product = service.proProduct;
    if (product == null) {
      await service.loadProducts();
      if (mounted) _showBillingMessage();
      return;
    }

    setState(() => _isBuying = true);
    await service.buyProduct(product);
    if (mounted) {
      setState(() => _isBuying = false);
      _showBillingMessage();
    }
  }

  void _showBillingMessage() {
    final service = PurchaseService.instance;
    final message = service.errorMessage ?? service.statusMessage;
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: service.errorMessage == null
            ? AppColors.primaryPurple
            : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    final isPro = context.watch<AppState>().isPro;
    final double bottomSafePadding = MediaQuery.of(context).viewPadding.bottom;
    final service = PurchaseService.instance;
    final product = service.proProduct;
    final isPurchaseActionEnabled =
        !service.isLoadingProducts &&
        service.initialized &&
        service.available &&
        !service.purchaseInProgress &&
        !service.purchasePending &&
        product != null;
    final isRestoreActionEnabled =
        !_isRestoring &&
        !service.purchaseInProgress &&
        !service.purchasePending &&
        service.initialized &&
        service.available;

    return AppScaffold(
      title: l10n.text('simple_pro'),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + bottomSafePadding + 96,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.2,
                            ),
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
                    if (!isPro) ...[
                      _buildPlanCard(
                        l10n.text('lifetime_plan'),
                        product?.price,
                        'simple_pro_lifetime',
                        product: product,
                      ),
                      _buildBillingStatus(product),
                      const SizedBox(height: 40),
                      GradientButton(
                        text:
                            _isBuying ||
                                service.purchasePending ||
                                service.purchaseInProgress
                            ? l10n.text('processing')
                            : l10n.text('activate_pro').toUpperCase(),
                        onPressed: isPurchaseActionEnabled ? _buyPremium : null,
                        borderRadius: 24,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: isRestoreActionEnabled
                            ? _restorePurchase
                            : null,
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

  Widget _buildPlanCard(
    String title,
    String? price,
    String productId, {
    bool isRecommended = false,
    ProductDetails? product,
  }) {
    final selected = _selectedProductId == productId;
    final l10n = context.watch<AppLocaleController>();
    final hasProduct = product != null;
    final displayTitle = hasProduct
        ? title
        : l10n.text('product_not_available');
    final supportingText = hasProduct
        ? l10n.text('one_time_payment')
        : l10n.text('product_price_pending');

    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = productId),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GlassCard(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            borderRadius: 24,
            glowColor: selected ? AppColors.primaryPurple : Colors.transparent,
            borderWidth: selected ? 2 : 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  hasProduct
                      ? Icons.workspace_premium_rounded
                      : Icons.info_outline_rounded,
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.softText.withValues(alpha: 0.45),
                  size: 34,
                ),
                const SizedBox(height: 14),
                Text(
                  displayTitle,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 18,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.softText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (hasProduct && price != null) ...[
                  Text(
                    price,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 30,
                      color: AppColors.primaryPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  supportingText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? AppColors.textPrimary.withValues(alpha: 0.65)
                        : AppColors.softText.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasProduct && product.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.softText.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.softText.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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

  Widget _buildBillingStatus(ProductDetails? product) {
    final service = PurchaseService.instance;
    final l10n = context.read<AppLocaleController>();
    final message =
        service.errorMessage ??
        service.statusMessage ??
        (service.isLoadingProducts ? l10n.text('loading_pro_product') : null) ??
        (product == null
            ? l10n.text('product_not_ready')
            : l10n.text('product_loaded'));

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: service.errorMessage == null
              ? AppColors.softText.withValues(alpha: 0.65)
              : Colors.redAccent,
        ),
        textAlign: TextAlign.center,
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
