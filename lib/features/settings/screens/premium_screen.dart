import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../services/purchase_service.dart';
import '../../../services/premium_service.dart';
import '../../../services/pro_service.dart';
import '../../../l10n/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = true;
  String _selectedProductId = 'simple_pro_monthly';

  @override
  void initState() {
    super.initState();
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    // Products are already loaded in main via PurchaseService.instance.init()
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
      // Mock purchase for testing if no products
      await PremiumService.instance.setPremium(true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.premium_test_unlocked),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.simple_pro),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.stars, size: 80, color: Colors.orange),
                      const SizedBox(height: 24),
                      Text(
                        l10n.simple_pro,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.unlock_advanced_tools,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildFeature(Icons.psychology, l10n.benefit_strategies),
                      _buildFeature(
                        Icons.trending_up,
                        l10n.benefit_predictions,
                      ),
                      _buildFeature(Icons.analytics, l10n.benefit_analytics),
                      _buildFeature(
                        Icons.lightbulb_outline,
                        l10n.smart_insights,
                      ),
                      const SizedBox(height: 40),
                      if (!ProService.instance.isPro) ...[
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedProductId = 'simple_pro_monthly';
                                  });
                                },
                                child: _buildPlanCard(
                                  l10n.monthly_plan,
                                  l10n.monthly_price,
                                  _selectedProductId == 'simple_pro_monthly',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedProductId = 'simple_pro_lifetime';
                                  });
                                },
                                child: _buildPlanCard(
                                  l10n.lifetime_plan,
                                  l10n.lifetime_price,
                                  _selectedProductId == 'simple_pro_lifetime',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _buyPremium,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.activate_pro,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _restorePurchase,
                          child: Text(
                            l10n.restore_purchase,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.pro_active,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
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
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected
            ? Colors.orange.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? Colors.orange : Colors.grey.withValues(alpha: 0.3),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: selected ? Colors.orange : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
