import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../core/state/app_state.dart';

/// Lo que PurchaseService usa de la tienda. En la app es Google Play
/// (`InAppPurchase.instance`); en los tests, una tienda falsa.
abstract class PurchaseStore {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids);
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});
  Future<void> completePurchase(PurchaseDetails purchase);
  Future<void> restorePurchases();
}

class _PlayStore implements PurchaseStore {
  InAppPurchase get _iap => InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) =>
      _iap.queryProductDetails(ids);

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      _iap.buyNonConsumable(purchaseParam: purchaseParam);

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);

  @override
  Future<void> restorePurchases() => _iap.restorePurchases();
}

class PurchaseService extends ChangeNotifier {
  static final PurchaseService instance = PurchaseService._init();
  static const String proProductId = 'simple_pro_lifetime';

  /// Cuánto se espera la respuesta de Google Play al restaurar.
  static const Duration restoreTimeout = Duration(seconds: 8);

  PurchaseStore? _storeOverride;
  PurchaseStore? _playStore;
  PurchaseStore get _store => _storeOverride ?? (_playStore ??= _PlayStore());

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<void>? _initFuture;
  Completer<void>? _restoreAnswer;

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

  /// Deja el servicio como recién creado y usando [store].
  @visibleForTesting
  void resetForTesting(PurchaseStore store) {
    _subscription?.cancel();
    _subscription = null;
    _storeOverride = store;
    _initFuture = null;
    _restoreAnswer = null;
    products = [];
    available = false;
    initialized = false;
    isLoadingProducts = false;
    purchasePending = false;
    isRestoring = false;
    purchaseInProgress = false;
    statusMessage = null;
    errorMessage = null;
  }

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
      available = await _store.isAvailable();
      if (!available) {
        initialized = true;
        statusMessage = 'Google Play Billing no esta disponible.';
        notifyListeners();
        return;
      }

      _subscription ??= _store.purchaseStream.listen(
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
      final response = await _store.queryProductDetails(ids);
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
      final launched = await _store.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!launched) {
        // Google Play no abrió la pantalla de pago: no queda una compra
        // "en curso" trabando los botones.
        purchaseInProgress = false;
        purchasePending = false;
        statusMessage = null;
        errorMessage = 'No se pudo abrir Google Play. Proba de nuevo.';
        notifyListeners();
      }
      return launched;
    } catch (e) {
      purchaseInProgress = false;
      purchasePending = false;
      errorMessage = 'No se pudo iniciar la compra.';
      debugPrint('Error buying product: $e');
      notifyListeners();
    }
    return false;
  }

  /// Busca en Google Play una compra anterior de PRO. Devuelve true si al
  /// terminar PRO está activo.
  Future<bool> restorePurchases() async {
    await _restorePurchases(showStatus: true);
    return AppState.instance.isPro;
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

    final answer = Completer<void>();
    try {
      isRestoring = true;
      if (showStatus) {
        statusMessage = 'Buscando compras anteriores...';
      }
      errorMessage = null;
      notifyListeners();
      _restoreAnswer = answer;
      await _store.restorePurchases();
      // La respuesta llega por purchaseStream (aunque no haya compras).
      await answer.future.timeout(restoreTimeout, onTimeout: () {});
      if (showStatus && !AppState.instance.isPro) {
        statusMessage = 'No se encontro una compra de PRO en esta cuenta.';
      }
    } catch (e) {
      errorMessage = 'No se pudieron restaurar las compras.';
      debugPrint('Error restoring purchases: $e');
    } finally {
      if (identical(_restoreAnswer, answer)) _restoreAnswer = null;
      isRestoring = false;
      notifyListeners();
    }
  }

  /// Google Play marca como "restaurada" toda compra de la cuenta, también
  /// las que todavía no se pagaron (pago pendiente en efectivo, por ejemplo).
  /// Solo una compra pagada activa PRO.
  static bool isPaid(PurchaseDetails purchase) {
    if (purchase is GooglePlayPurchaseDetails) {
      return purchase.billingClientPurchase.purchaseState ==
          PurchaseStateWrapper.purchased;
    }
    return true;
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending ||
          ((purchaseDetails.status == PurchaseStatus.purchased ||
                  purchaseDetails.status == PurchaseStatus.restored) &&
              !isPaid(purchaseDetails))) {
        // Pendiente de pago: no se activa PRO ni se confirma la compra.
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
          try {
            await _store.completePurchase(purchaseDetails);
          } catch (e) {
            // Si no se confirma, Google Play la devuelve en el próximo
            // arranque y se vuelve a intentar.
            debugPrint('Complete purchase error: $e');
          }
        }
        notifyListeners();
      }
    }
    final answer = _restoreAnswer;
    if (answer != null && !answer.isCompleted) answer.complete();
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
