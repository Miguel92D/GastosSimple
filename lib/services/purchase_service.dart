import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';

class PurchaseService {
  static final PurchaseService instance = PurchaseService._init();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> products = [];
  bool available = false;

  PurchaseService._init();

  Future<void> init() async {
    available = await _iap.isAvailable();
    if (available) {
      await loadProducts();
      final purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription.cancel();
        },
        onError: (error) {
          debugPrint('Purchase Stream Error: $error');
        },
      );
    }
  }

  Future<void> loadProducts() async {
    const ids = {'simple_pro_monthly', 'simple_pro_lifetime'};
    final response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    products = response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      if (product.id == 'simple_pro_monthly' ||
          product.id == 'simple_pro_lifetime') {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('Error buying product: $e');
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending state if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == 'simple_pro_monthly' ||
        purchaseDetails.productID == 'simple_pro_lifetime') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_pro', true);

      PremiumService.instance.setPremium(true);
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
