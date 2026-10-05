// Pro y compras (chat 04): compra y restauración de simple_pro_lifetime con
// una tienda falsa en lugar de Google Play. Pro solo se activa con una compra
// pagada; nunca se fuerza en el código.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/services/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _pro = ProductDetails(
  id: PurchaseService.proProductId,
  title: r'$imple PRO',
  description: 'Pago único',
  price: r'$ 4.990',
  rawPrice: 4990,
  currencyCode: 'ARS',
);

PurchaseDetails _purchase(
  PurchaseStatus status, {
  String productId = PurchaseService.proProductId,
  bool needsComplete = true,
  IAPError? error,
}) {
  final purchase = PurchaseDetails(
    purchaseID: 'GPA.1',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '{}',
      serverVerificationData: 'token',
      source: 'test',
    ),
    transactionDate: '0',
    status: status,
  );
  purchase.pendingCompletePurchase = needsComplete;
  purchase.error = error;
  return purchase;
}

/// Como llega de Google Play al restaurar: siempre con estado "restored",
/// aunque la compra todavía no esté pagada.
GooglePlayPurchaseDetails _playRestored(PurchaseStateWrapper state) {
  final wrapper = PurchaseWrapper(
    orderId: 'GPA.2',
    packageName: 'com.migueld.gastossimple',
    purchaseTime: 0,
    purchaseToken: 'token',
    signature: 'firma',
    products: const [PurchaseService.proProductId],
    isAutoRenewing: false,
    originalJson: '{}',
    isAcknowledged: false,
    purchaseState: state,
  );
  return GooglePlayPurchaseDetails.fromPurchase(wrapper).single
    ..status = PurchaseStatus.restored;
}

class _FakeStore implements PurchaseStore {
  final _stream = StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  List<ProductDetails> products = [_pro];

  /// Lo que Google Play tiene registrado para esta cuenta.
  List<PurchaseDetails> owned = [];

  /// Lo que pasa al tocar comprar (null = el usuario sigue en Google Play).
  List<PurchaseDetails>? onBuy;
  bool launchResult = true;
  bool answerRestore = true;

  final List<PurchaseDetails> completed = [];
  int buyCalls = 0;

  void emit(List<PurchaseDetails> purchases) => _stream.add(purchases);

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async {
    final found = products.where((p) => ids.contains(p.id)).toList();
    return ProductDetailsResponse(
      productDetails: found,
      notFoundIDs: ids.where((id) => !found.any((p) => p.id == id)).toList(),
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalls++;
    final result = onBuy;
    if (launchResult && result != null) {
      scheduleMicrotask(() => emit(result));
    }
    return launchResult;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
  }

  @override
  Future<void> restorePurchases() async {
    // Google Play responde por el stream, también cuando no hay compras.
    if (answerRestore) scheduleMicrotask(() => emit(List.of(owned)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeStore store;
  final service = PurchaseService.instance;

  Future<bool> savedPro() async =>
      (await SharedPreferences.getInstance()).getBool('is_pro') ?? false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppState.instance.setPro(false);
    store = _FakeStore();
    service.resetForTesting(store);
  });

  group('Arranque', () {
    test('sin compras, PRO queda apagado', () async {
      await service.init();

      expect(service.initialized, isTrue);
      expect(service.proProduct?.id, PurchaseService.proProductId);
      expect(AppState.instance.isPro, isFalse);
      expect(await savedPro(), isFalse);
    });

    test('con una compra pagada en la cuenta, PRO se activa solo', () async {
      store.owned = [_purchase(PurchaseStatus.restored)];

      await service.init();

      expect(AppState.instance.isPro, isTrue);
      expect(await savedPro(), isTrue);
    });

    test('PRO guardado en el teléfono se lee al abrir la app', () async {
      SharedPreferences.setMockInitialValues({'is_pro': true});
      await AppState.instance.loadProEntitlement();
      expect(AppState.instance.isPro, isTrue);
    });

    test('sin Google Play no se puede comprar ni se activa PRO', () async {
      store.available = false;
      await service.init();

      expect(await service.buyProduct(_pro), isFalse);
      expect(store.buyCalls, 0);
      expect(AppState.instance.isPro, isFalse);
    });

    test('si el producto no está en Play, no hay botón de compra', () async {
      store.products = [];
      await service.init();

      expect(service.proProduct, isNull);
      expect(service.statusMessage, contains('no esta configurado'));
    });
  });

  group('Compra', () {
    test('compra pagada: activa PRO, lo guarda y la confirma', () async {
      await service.init();
      final bought = _purchase(PurchaseStatus.purchased);
      store.onBuy = [bought];

      expect(await service.buyProduct(service.proProduct!), isTrue);
      await pumpEventQueue();

      expect(AppState.instance.isPro, isTrue);
      expect(await savedPro(), isTrue);
      expect(store.completed, [bought]);
      expect(service.purchaseInProgress, isFalse);
      expect(service.purchasePending, isFalse);
    });

    test('compra cancelada: no hay PRO y se puede volver a intentar', () async {
      await service.init();
      store.onBuy = [_purchase(PurchaseStatus.canceled, needsComplete: false)];

      await service.buyProduct(_pro);
      await pumpEventQueue();

      expect(AppState.instance.isPro, isFalse);
      expect(service.purchaseInProgress, isFalse);
      expect(service.statusMessage, 'Compra cancelada.');
    });

    test('error de Google Play: muestra el mensaje y no activa PRO', () async {
      await service.init();
      store.onBuy = [
        _purchase(
          PurchaseStatus.error,
          needsComplete: false,
          error: IAPError(
            source: 'test',
            code: 'x',
            message: 'Tarjeta rechazada',
          ),
        ),
      ];

      await service.buyProduct(_pro);
      await pumpEventQueue();

      expect(AppState.instance.isPro, isFalse);
      expect(service.errorMessage, 'Tarjeta rechazada');
      expect(service.purchasePending, isFalse);
    });

    test('pago pendiente: espera sin activar PRO hasta que se paga', () async {
      await service.init();
      store.onBuy = [_purchase(PurchaseStatus.pending, needsComplete: false)];

      await service.buyProduct(_pro);
      await pumpEventQueue();
      expect(AppState.instance.isPro, isFalse);
      expect(service.purchasePending, isTrue);
      // Mientras está pendiente no se abre una segunda compra.
      expect(await service.buyProduct(_pro), isFalse);
      expect(store.buyCalls, 1);

      store.emit([_purchase(PurchaseStatus.purchased)]);
      await pumpEventQueue();
      expect(AppState.instance.isPro, isTrue);
      expect(service.purchasePending, isFalse);
    });

    test(
      'si Google Play no abre el pago, los botones no quedan trabados',
      () async {
        await service.init();
        store.launchResult = false;

        expect(await service.buyProduct(_pro), isFalse);
        expect(service.purchaseInProgress, isFalse);
        expect(service.purchasePending, isFalse);
        expect(service.errorMessage, isNotNull);
      },
    );

    test('una compra de otro producto no activa PRO', () async {
      await service.init();
      store.emit([_purchase(PurchaseStatus.purchased, productId: 'otro')]);
      await pumpEventQueue();

      expect(AppState.instance.isPro, isFalse);
    });
  });

  group('Restaurar', () {
    test('encuentra la compra: activa PRO y devuelve true', () async {
      await service.init();
      store.owned = [_purchase(PurchaseStatus.restored)];

      expect(await service.restorePurchases(), isTrue);
      expect(AppState.instance.isPro, isTrue);
      expect(await savedPro(), isTrue);
      expect(service.statusMessage, contains('restaurada'));
      expect(service.isRestoring, isFalse);
    });

    test('sin compras: devuelve false y lo dice', () async {
      await service.init();

      expect(await service.restorePurchases(), isFalse);
      expect(AppState.instance.isPro, isFalse);
      expect(service.statusMessage, contains('No se encontro'));
    });

    test('compra pagada que llega de Google Play: activa PRO', () async {
      await service.init();
      store.owned = [_playRestored(PurchaseStateWrapper.purchased)];

      expect(await service.restorePurchases(), isTrue);
      expect(store.completed, hasLength(1));
    });

    test(
      'compra sin pagar (Play la marca restaurada): NO activa PRO',
      () async {
        store.owned = [_playRestored(PurchaseStateWrapper.pending)];
        await service.init();

        expect(AppState.instance.isPro, isFalse);
        expect(await savedPro(), isFalse);
        // Una compra sin pagar no se confirma.
        expect(store.completed, isEmpty);
      },
    );

    testWidgets('si Google Play no contesta, no se queda esperando', (
      tester,
    ) async {
      store.answerRestore = false;
      const wait = PurchaseService.restoreTimeout;
      final init = service.init();
      await tester.pump(wait + const Duration(seconds: 1));
      await init;

      bool? result;
      service.restorePurchases().then((value) => result = value);
      await tester.pump(wait + const Duration(seconds: 1));

      expect(result, isFalse);
      expect(service.isRestoring, isFalse);
    });
  });

  test('nadie fuerza PRO en el código: solo PurchaseService lo activa', () {
    final forcing = RegExp(
      r'setProEntitlement\(\s*true|setPro\(\s*true|_isPro\s*=\s*true',
    );
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final path = file.path.replaceAll('\\', '/');
      if (path.endsWith('lib/services/purchase_service.dart')) continue;
      if (forcing.hasMatch(file.readAsStringSync())) offenders.add(path);
    }
    expect(offenders, isEmpty);
    expect(
      File('lib/services/purchase_service.dart').readAsStringSync(),
      contains('setProEntitlement(true)'),
    );
  });
}
