import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../core/i18n/app_locale_controller.dart';
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

/// Mensajes en el idioma de la app (P-14).
String _t(String key) => AppLocaleController.instance.text(key);

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
  Future<void>? _checking;

  /// Respuesta de Google Play a un pedido de restaurar: true si trajo una
  /// compra de PRO pagada.
  Completer<bool>? _restoreAnswer;

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
    _checking = null;
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
        statusMessage = _t('purchase_billing_unavailable');
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
          errorMessage = _t('purchase_process_failed');
          debugPrint('Purchase Stream Error: $error');
          notifyListeners();
        },
      );

      await loadProducts();
      initialized = true;
      await recheckOwnedPurchases();
    } catch (e) {
      initialized = true;
      errorMessage = _t('purchase_billing_init_failed');
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
        statusMessage = _t('purchase_product_not_configured');
        debugPrint('Products not found: ${response.notFoundIDs}');
      } else {
        statusMessage = null;
      }
      products = response.productDetails;
    } catch (e) {
      errorMessage = _t('purchase_product_load_failed');
      debugPrint('Product load error: $e');
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (!available || !initialized) {
      errorMessage = _t('purchase_billing_not_ready');
      notifyListeners();
      return false;
    }
    if (isLoadingProducts) {
      errorMessage = _t('purchase_product_loading');
      notifyListeners();
      return false;
    }
    if (purchaseInProgress || purchasePending) {
      statusMessage = _t('purchase_in_progress');
      notifyListeners();
      return false;
    }
    if (product.id != proProductId || proProduct == null) {
      errorMessage = _t('purchase_product_unavailable');
      notifyListeners();
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      purchaseInProgress = true;
      purchasePending = true;
      statusMessage = _t('purchase_opening_play');
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
        errorMessage = _t('purchase_open_play_failed');
        notifyListeners();
      }
      return launched;
    } catch (e) {
      purchaseInProgress = false;
      purchasePending = false;
      errorMessage = _t('purchase_start_failed');
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

  /// Vuelve a preguntarle a Google Play si la compra de PRO sigue vigente
  /// (D-027): al abrir la pantalla Pro o Configuración. Nunca corren dos
  /// revisiones a la vez.
  Future<void> refreshOwnership() {
    // El arranque ya revisa: no hace falta otra vuelta.
    if (_initFuture == null) return init();
    return _checking ??= _initFuture!
        .then((_) => recheckOwnedPurchases())
        .whenComplete(() => _checking = null);
  }

  /// Al volver a la app: solo si está guardado PRO, para no cruzarse con la
  /// compra en curso de alguien que está en Gratis.
  Future<void> refreshOwnershipIfPro() async {
    if (!AppState.instance.isPro) return;
    await refreshOwnership();
  }

  Future<void> _restorePurchases({required bool showStatus}) async {
    if (!available || !initialized) {
      if (showStatus) {
        errorMessage = _t('purchase_billing_not_ready');
        notifyListeners();
      }
      return;
    }
    if (purchaseInProgress || purchasePending) {
      if (showStatus) {
        statusMessage = _t('purchase_wait_current');
        notifyListeners();
      }
      return;
    }

    final answer = Completer<bool>();
    try {
      isRestoring = true;
      if (showStatus) {
        statusMessage = _t('purchase_searching');
      }
      errorMessage = null;
      notifyListeners();
      _restoreAnswer = answer;
      await _store.restorePurchases();
      // La respuesta llega por purchaseStream (aunque no haya compras).
      // null = Google Play no contestó a tiempo.
      final bool? hasPaidPro = await answer.future
          .then<bool?>((value) => value)
          .timeout(restoreTimeout, onTimeout: () => null);
      if (hasPaidPro == false && AppState.instance.isPro) {
        // Google Play contestó bien y la compra ya no está (por ejemplo,
        // se devolvió el dinero): vuelve a Gratis. Con error o sin
        // respuesta no se toca nada (catch y null).
        await AppState.instance.setProEntitlement(false);
      }
      if (showStatus && !AppState.instance.isPro) {
        statusMessage = _t('purchase_not_found');
      }
    } catch (e) {
      errorMessage = _t('purchase_restore_failed');
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
        statusMessage = _t('purchase_pending');
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          purchaseInProgress = false;
          purchasePending = false;
          final purchaseErrorMessage = purchaseDetails.error?.message.trim();
          errorMessage =
              purchaseErrorMessage != null && purchaseErrorMessage.isNotEmpty
              ? purchaseErrorMessage
              : _t('purchase_not_completed');
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          purchaseInProgress = false;
          purchasePending = false;
          statusMessage = _t('purchase_canceled');
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
    if (answer != null && !answer.isCompleted) {
      answer.complete(
        purchaseDetailsList.any(
          (p) =>
              p.productID == proProductId &&
              (p.status == PurchaseStatus.purchased ||
                  p.status == PurchaseStatus.restored) &&
              isPaid(p),
        ),
      );
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == proProductId) {
      await AppState.instance.setProEntitlement(true);
      statusMessage = purchaseDetails.status == PurchaseStatus.restored
          ? _t('purchase_restored_active')
          : _t('purchase_completed_active');
      errorMessage = null;
    } else {
      statusMessage = _t('purchase_unknown_product');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
