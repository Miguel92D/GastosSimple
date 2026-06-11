import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../core/state/app_state.dart';

class PurchaseService extends ChangeNotifier {
  static final PurchaseService instance = PurchaseService._init();
  static const String proProductId = 'simple_pro_lifetime';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<void>? _initFuture;

  List<ProductDetails> products = [];
  bool available = false;
  bool initialized = false;
  bool isLoadingProducts = false;
  bool purchasePending = false;
  bool isRestoring = false;
  bool purchaseInProgress = false;
  String? statusMessage;
  String? errorMessage;

  PurchaseService._init();

  Future<void> init() async {
    _initFuture ??= _init();
    return _initFuture!;
  }

  ProductDetails? get proProduct {
    for (final product in products) {
      if (product.id == proProductId) return product;
    }
    return null;
  }

  bool get hasProProduct => proProduct != null;

  Future<void> _init() async {
    try {
      available = await _iap.isAvailable();
      if (!available) {
        initialized = true;
        statusMessage = 'Google Play Billing no esta disponible.';
        notifyListeners();
        return;
      }

      _subscription ??= _iap.purchaseStream.listen(
        (purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription?.cancel();
          _subscription = null;
        },
        onError: (error) {
          errorMessage = 'No se pudo procesar la compra.';
          debugPrint('Purchase Stream Error: $error');
          notifyListeners();
        },
      );

      await loadProducts();
      initialized = true;
      await recheckOwnedPurchases();
    } catch (e) {
      initialized = true;
      errorMessage = 'No se pudo inicializar Google Play Billing.';
      debugPrint('Billing init error: $e');
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      const ids = {proProductId};
      final response = await _iap.queryProductDetails(ids);
      if (response.notFoundIDs.isNotEmpty) {
        statusMessage = 'El producto PRO no esta configurado en Play.';
        debugPrint('Products not found: ${response.notFoundIDs}');
      } else {
        statusMessage = null;
      }
      products = response.productDetails;
    } catch (e) {
      errorMessage = 'No se pudo cargar el producto PRO.';
      debugPrint('Product load error: $e');
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (!available || !initialized) {
      errorMessage = 'Google Play Billing no esta listo todavia.';
      notifyListeners();
      return false;
    }
    if (isLoadingProducts) {
      errorMessage = 'El producto PRO todavia se esta cargando.';
      notifyListeners();
      return false;
    }
    if (purchaseInProgress || purchasePending) {
      statusMessage = 'Ya hay una compra en curso.';
      notifyListeners();
      return false;
    }
    if (product.id != proProductId || proProduct == null) {
      errorMessage = 'El producto PRO no esta disponible ahora.';
      notifyListeners();
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      purchaseInProgress = true;
      purchasePending = true;
      statusMessage = 'Abriendo Google Play...';
      errorMessage = null;
      notifyListeners();
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      purchaseInProgress = false;
      purchasePending = false;
      errorMessage = 'No se pudo iniciar la compra.';
      debugPrint('Error buying product: $e');
      notifyListeners();
    }
    return false;
  }

  Future<void> restorePurchases() async {
    await _restorePurchases(showStatus: true);
  }

  Future<void> recheckOwnedPurchases() async {
    await _restorePurchases(showStatus: false);
  }

  Future<void> _restorePurchases({required bool showStatus}) async {
    if (!available || !initialized) {
      if (showStatus) {
        errorMessage = 'Google Play Billing no esta listo todavia.';
        notifyListeners();
      }
      return;
    }
    if (purchaseInProgress || purchasePending) {
      if (showStatus) {
        statusMessage = 'Espera a que termine la compra actual.';
        notifyListeners();
      }
      return;
    }

    try {
      isRestoring = true;
      if (showStatus) {
        statusMessage = 'Buscando compras anteriores...';
      }
      errorMessage = null;
      notifyListeners();
      await _iap.restorePurchases();
    } catch (e) {
      errorMessage = 'No se pudieron restaurar las compras.';
      debugPrint('Error restoring purchases: $e');
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        purchaseInProgress = true;
        purchasePending = true;
        statusMessage = 'La compra esta pendiente de confirmacion.';
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          purchaseInProgress = false;
          purchasePending = false;
          final purchaseErrorMessage = purchaseDetails.error?.message.trim();
          errorMessage =
              purchaseErrorMessage != null && purchaseErrorMessage.isNotEmpty
              ? purchaseErrorMessage
              : 'La compra no se pudo completar.';
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          purchaseInProgress = false;
          purchasePending = false;
          statusMessage = 'Compra cancelada.';
          errorMessage = null;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _deliverProduct(purchaseDetails);
          purchaseInProgress = false;
          purchasePending = false;
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        notifyListeners();
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == proProductId) {
      await AppState.instance.setProEntitlement(true);
      statusMessage = purchaseDetails.status == PurchaseStatus.restored
          ? 'Compra restaurada. PRO esta activo.'
          : 'Compra completada. PRO esta activo.';
      errorMessage = null;
    } else {
      statusMessage = 'Compra recibida para un producto no reconocido.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
