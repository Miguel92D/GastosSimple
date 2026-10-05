import 'dart:async';

// Pro y Bóveda (chat 04): la pantalla Pro y el aviso solo prometen lo que es
// PRO (P-05 / P-08), las pantallas PRO no se abren sin PRO, la Bóveda se tapa
// cuando está cerrada y sus movimientos nunca se mezclan con los normales
// (Especificación §7). La parte de datos usa SQLite en memoria (D-014).
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/flow/premium_flow_service.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/i18n/app_translations.dart';
import 'package:gastos_simple/core/router/app_router.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/database/database_helper.dart';
import 'package:gastos_simple/features/dashboard/controllers/dashboard_controller.dart';
import 'package:gastos_simple/features/settings/screens/premium_screen.dart';
import 'package:gastos_simple/features/settings/widgets/manage_purchase_button.dart';
import 'package:gastos_simple/features/transactions/controllers/transaction_controller.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/features/vault/controllers/vault_controller.dart';
import 'package:gastos_simple/features/vault/widgets/vault_lock_gate.dart';
import 'package:gastos_simple/services/purchase_service.dart';
import 'package:gastos_simple/services/security_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

/// Tienda que no tiene el producto: alcanza para dibujar la pantalla Pro.
class _EmptyStore implements PurchaseStore {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(productDetails: [], notFoundIDs: ids.toList());
  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      false;
  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}
  @override
  Future<void> restorePurchases() async {}
}

/// Google Play que contesta: con la compra de PRO pagada o sin ella.
class _PlayStore implements PurchaseStore {
  _PlayStore({required this.paid});
  final bool paid;
  final _stream = StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(productDetails: [], notFoundIDs: ids.toList());
  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      false;
  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}
  @override
  Future<void> restorePurchases() async {
    final owned = [
      if (paid)
        PurchaseDetails(
          productID: PurchaseService.proProductId,
          verificationData: PurchaseVerificationData(
            localVerificationData: '{}',
            serverVerificationData: 'token',
            source: 'test',
          ),
          transactionDate: '0',
          status: PurchaseStatus.restored,
        ),
    ];
    scheduleMicrotask(() => _stream.add(owned));
  }
}

Widget _app(Widget child) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: AppLocaleController.instance),
    ChangeNotifierProvider.value(value: AppState.instance),
    ChangeNotifierProvider.value(value: SecurityService.instance),
  ],
  child: MaterialApp(home: child),
);

String _t(String key) => AppLocaleController.instance.text(key);

/// Lo que es PRO según P-05, y lo que ya no se puede prometer (P-08).
const _proKeys = [
  'pro_benefit_stats',
  'pro_benefit_goals',
  'pro_benefit_vault',
  'pro_benefit_debt_tips',
];
const _notProKeys = [
  'benefit_predictions',
  'feature_export',
  'smart_insights',
  'benefit_analytics',
];

Transaction _mov(
  double amount, {
  int isSecret = 0,
  String type = Transaction.typeExpense,
  String category = 'Comida',
  String? note,
}) => Transaction(
  amount: amount,
  category: category,
  type: type,
  date: DateTime.now(),
  isSecret: isSecret,
  note: note,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AppState.instance.setPro(false);
    PurchaseService.instance.resetForTesting(_EmptyStore());
  });

  group('Lo que promete PRO (P-08)', () {
    testWidgets('la pantalla Pro muestra solo lo que es PRO', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const PremiumScreen()));
      await tester.pumpAndSettle();

      for (final key in _proKeys) {
        expect(find.text(_t(key)), findsOneWidget, reason: key);
      }
      for (final key in _notProKeys) {
        expect(find.text(_t(key)), findsNothing, reason: key);
      }
    });

    testWidgets('el aviso de mejora muestra lo mismo y no habla de prueba', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => PremiumFlowService.showUpgradePrompt(context),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(PremiumFlowService.proBenefitKeys, _proKeys);
      for (final key in _proKeys) {
        expect(find.text(_t(key)), findsOneWidget, reason: key);
      }
      for (final key in _notProKeys) {
        expect(find.text(_t(key)), findsNothing, reason: key);
      }
      // Es un pago único: no hay período de prueba.
      expect(find.textContaining('Probar'), findsNothing);
    });

    test('los textos PRO existen en español y en inglés', () {
      for (final lang in ['es', 'en']) {
        final texts = AppTranslations.translations[lang]!;
        for (final key in [
          ..._proKeys,
          'try_premium',
          'vault_locked_title',
          'vault_locked_body',
          'vault_open',
        ]) {
          expect(texts[key], isNotNull, reason: '$lang:$key');
        }
      }
    });
  });

  group('Pantalla Pro y la compra en Google Play (D-027)', () {
    Future<void> openPremium(WidgetTester tester, {required bool paid}) async {
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'is_pro': true});
      await AppState.instance.loadProEntitlement();
      PurchaseService.instance.resetForTesting(_PlayStore(paid: paid));

      await tester.pumpWidget(_app(const PremiumScreen()));
      await tester.pumpAndSettle();
    }

    testWidgets('se devolvió el dinero: al abrir la pantalla vuelve a Gratis', (
      tester,
    ) async {
      await openPremium(tester, paid: false);

      expect(AppState.instance.isPro, isFalse);
      expect(find.text(_t('pro_active')), findsNothing);
      expect(find.byType(ManagePurchaseButton), findsNothing);
    });

    testWidgets('sigue pagada: sigue PRO y se puede ver la compra', (
      tester,
    ) async {
      await openPremium(tester, paid: true);

      expect(AppState.instance.isPro, isTrue);
      expect(find.text(_t('pro_active')), findsOneWidget);
      expect(find.byType(ManagePurchaseButton), findsOneWidget);
      expect(find.text(_t('premium_google_play_manage_note')), findsOneWidget);
    });

    testWidgets('el botón abre el historial de pedidos de Google Play', (
      tester,
    ) async {
      final original = ManagePurchaseButton.opener;
      addTearDown(() => ManagePurchaseButton.opener = original);
      Uri? opened;
      ManagePurchaseButton.opener = (uri) async {
        opened = uri;
        return false; // Play Store no se pudo abrir
      };
      await openPremium(tester, paid: true);

      await tester.tap(find.text(_t('premium_manage_purchase')));
      await tester.pump();

      expect(
        opened.toString(),
        'https://play.google.com/store/account/orderhistory',
      );
      expect(find.text(_t('premium_manage_open_failed')), findsOneWidget);
    });

    test('textos de la compra en español y en inglés', () {
      for (final lang in ['es', 'en']) {
        final texts = AppTranslations.translations[lang]!;
        for (final key in [
          'premium_manage_purchase',
          'premium_manage_open_failed',
          'premium_google_play_manage_note',
        ]) {
          expect(texts[key], isNotNull, reason: '$lang:$key');
        }
      }
      // Pago único: el aviso no habla de cancelar una suscripción.
      expect(
        AppTranslations.translations['es']!['premium_google_play_manage_note'],
        contains('no hay suscripción que cancelar'),
      );
    });
  });

  group('Pantallas PRO sin PRO', () {
    Widget? screenFor(BuildContext context, String name, [Object? args]) {
      final route = AppRouter.generateRoute(
        RouteSettings(name: name, arguments: args),
      );
      return (route as MaterialPageRoute).builder(context);
    }

    testWidgets('sin PRO, cualquier ruta PRO abre la pantalla Pro', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );

      for (final name in AppRouter.proRoutes) {
        expect(screenFor(context, name), isA<PremiumScreen>(), reason: name);
      }
      // Cargar un movimiento en la Bóveda también es PRO.
      expect(
        screenFor(context, '/add', {'isVault': true}),
        isA<PremiumScreen>(),
      );
      expect(screenFor(context, '/add'), isNot(isA<PremiumScreen>()));
      // Los pagos fijos de la Bóveda quedan detrás de la puerta.
      expect(
        screenFor(context, '/recurring', {'isVault': true}),
        isA<VaultLockGate>(),
      );

      AppState.instance.setPro(true);
      expect(screenFor(context, '/stats'), isNot(isA<PremiumScreen>()));
    });
  });

  group('Puerta de la Bóveda', () {
    test('solo se ve con PRO y, si tiene PIN, abierta', () {
      expect(
        VaultLockGate.canShow(
          isPro: false,
          vaultPinActive: false,
          vaultUnlocked: true,
        ),
        isFalse,
      );
      expect(
        VaultLockGate.canShow(
          isPro: true,
          vaultPinActive: false,
          vaultUnlocked: false,
        ),
        isTrue,
      );
      expect(
        VaultLockGate.canShow(
          isPro: true,
          vaultPinActive: true,
          vaultUnlocked: false,
        ),
        isFalse,
      );
      expect(
        VaultLockGate.canShow(
          isPro: true,
          vaultPinActive: true,
          vaultUnlocked: true,
        ),
        isTrue,
      );
    });

    testWidgets('al volver de segundo plano lo secreto queda tapado', (
      tester,
    ) async {
      final security = SecurityService.instance;
      AppState.instance.setPro(true);
      await security.setVaultPinActive(true);
      addTearDown(() => security.setVaultPinActive(false));
      security.unlockVault();

      await tester.pumpWidget(
        _app(const VaultLockGate(title: 'Bóveda', child: Text('SECRETO'))),
      );
      expect(find.text('SECRETO'), findsOneWidget);

      // Lo que hace main.dart cuando la app pasa a segundo plano.
      security.lock();
      await tester.pump();
      expect(find.text('SECRETO'), findsNothing);
      expect(find.text(_t('vault_locked_title')), findsOneWidget);
      expect(find.text(_t('vault_open')), findsOneWidget);

      security.unlockVault();
      await tester.pump();
      expect(find.text('SECRETO'), findsOneWidget);
    });

    testWidgets('sin PRO la Bóveda no se ve y ofrece PRO', (tester) async {
      await tester.pumpWidget(
        _app(const VaultLockGate(title: 'Bóveda', child: Text('SECRETO'))),
      );
      expect(find.text('SECRETO'), findsNothing);
      expect(find.text(_t('try_premium')), findsOneWidget);
    });
  });

  group('Bóveda aislada (Especificación §7)', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      DatabaseHelper.pathOverride = inMemoryDatabasePath;
    });
    setUp(DatabaseHelper.resetForTesting);
    tearDownAll(DatabaseHelper.resetForTesting);

    Future<void> seed() async {
      await TransactionController.addTransaction(_mov(100, note: 'súper'));
      await TransactionController.addTransaction(
        _mov(1000, type: Transaction.typeIncome, note: 'sueldo'),
      );
      await TransactionController.addTransaction(
        _mov(777, isSecret: 1, category: 'Secreta', note: 'súper secreto'),
      );
      await TransactionController.addTransaction(
        _mov(5000, isSecret: 1, type: Transaction.typeIncome, note: 'extra'),
      );
    }

    test('nada secreto en historial, búsquedas, tipos ni categorías', () async {
      await seed();
      final listas = {
        'historial': await TransactionController.getNormalHistory(),
        'gastos': await TransactionController.getExpense(),
        'ingresos': await TransactionController.getIncome(),
        'buscar': await TransactionController.search('súper'),
        'buscar por tipo': await TransactionController.searchByType(
          'súper',
          Transaction.typeExpense,
        ),
        'mes': await TransactionController.getTransactionsInMonth(),
        'hoy': await TransactionController.getTransactionsForDay(
          DateTime.now(),
        ),
      };
      for (final entry in listas.entries) {
        expect(entry.value, isNotEmpty, reason: entry.key);
        expect(
          entry.value.where((t) => t.isSecret == 1),
          isEmpty,
          reason: entry.key,
        );
      }
      expect(
        await TransactionController.getCategoriasOrdenadas(
          Transaction.typeExpense,
        ),
        isNot(contains('Secreta')),
      );
    });

    test(
      'el saldo normal no cuenta la Bóveda y la Bóveda solo lo suyo',
      () async {
        await seed();
        final dashboard = DashboardController();

        expect(await dashboard.getBalance(false), 900);
        expect(await dashboard.getBalance(true), 4223);
        final vault = await VaultController.getVaultTransactions();
        expect(vault.every((t) => t.isSecret == 1), isTrue);
        expect(vault, hasLength(2));
      },
    );

    test('editar un movimiento secreto lo deja en la Bóveda', () async {
      await seed();
      final secreto = (await VaultController.getVaultTransactions()).firstWhere(
        (t) => t.amount == 777,
      );

      await TransactionController.updateTransaction(
        secreto.copyWith(amount: 800, note: 'otro'),
      );

      final normal = await TransactionController.getNormalHistory();
      expect(normal.any((t) => t.amount == 800), isFalse);
      final vault = await VaultController.getVaultTransactions();
      expect(vault.any((t) => t.amount == 800 && t.isSecret == 1), isTrue);
    });

    test('mandar a la Bóveda y sacarlo mueve el movimiento entero', () async {
      await seed();
      final gasto = (await TransactionController.getNormalHistory()).firstWhere(
        (t) => t.amount == 100,
      );

      await VaultController.moveToVault(gasto);
      expect(
        (await TransactionController.getNormalHistory()).map((t) => t.amount),
        isNot(contains(100)),
      );
      final enBoveda = (await VaultController.getVaultTransactions())
          .firstWhere((t) => t.amount == 100);

      await VaultController.removeFromVault(enBoveda);
      expect(
        (await TransactionController.getNormalHistory()).map((t) => t.amount),
        contains(100),
      );
    });

    test('los pagos fijos de la Bóveda no salen en la lista normal', () async {
      await TransactionController.addRecurringTransaction(
        _mov(300, isSecret: 1, category: 'Secreta'),
        'monthly',
      );
      await TransactionController.addRecurringTransaction(_mov(50), 'monthly');

      final normal = await TransactionController.getRecurringPayments();
      final vault = await TransactionController.getRecurringPayments(
        isVault: true,
      );
      expect(normal.map((p) => p.amount), [50]);
      expect(vault.map((p) => p.amount), [300]);
      expect(vault.single.isSecret, isTrue);
    });
  });
}
