// Pantallas del núcleo (agregar/editar, Movimientos, Pagos fijos) de verdad
// (chat 02). La base es SQLite en memoria (sqflite_common_ffi).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gastos_simple/core/router/navigation_service.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/database/database_helper.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/features/transactions/controllers/transaction_controller.dart';
import 'package:gastos_simple/features/transactions/screens/add_transaction_screen.dart';
import 'package:gastos_simple/features/transactions/screens/movements_screen.dart';
import 'package:gastos_simple/features/transactions/screens/recurring_screen.dart';
import 'package:gastos_simple/services/currency_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseHelper.resetForTesting();
  });

  tearDownAll(DatabaseHelper.resetForTesting);

  Widget app(Widget screen) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: AppLocaleController.instance),
      ChangeNotifierProvider.value(value: AppState.instance),
      ChangeNotifierProvider.value(value: CurrencyService.instance),
    ],
    child: MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      // Pantalla de abajo, para que "volver" después de guardar funcione.
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => screen)),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );

  // La base trabaja en otro hilo: se le da tiempo real varias veces, porque
  // guardar encadena varias consultas.
  Future<void> settleDb(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> openAndSave(
    WidgetTester tester,
    Widget screen,
    String amount,
  ) async {
    await tester.pumpWidget(app(screen));
    await tester.tap(find.text('abrir'));
    await settleDb(tester);

    await tester.enterText(find.byType(TextField).first, amount);
    await tester.pump();
    final save = find.text(
      AppLocaleController.instance.text('save').toUpperCase(),
    );
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settleDb(tester);
  }

  testWidgets('anotar un gasto nuevo lo guarda y vuelve atrás', (tester) async {
    await openAndSave(
      tester,
      const AddTransactionScreen(type: 'expense'),
      '250',
    );

    final saved = await tester.runAsync(_rows);
    expect(saved, hasLength(1));
    expect(saved!.single['amount'], 250);
    expect(saved.single['type'], Transaction.typeExpense);
    expect(saved.single['is_secret'], 0);
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets(
    'editar un movimiento de la Bóveda conserva isSecret, pago fijo y meta',
    (tester) async {
      final original = Transaction(
        amount: 100,
        category: 'Suscripciones',
        type: Transaction.typeExpense,
        date: DateTime.now().subtract(const Duration(days: 3)),
        isSecret: 1,
        isRecurring: true,
        goalId: 4,
        goalAmount: 10,
      );
      final id = (await tester.runAsync(
        () => DatabaseHelper.instance.insertTransaction(original),
      ))!;

      await openAndSave(
        tester,
        AddTransactionScreen(movimientoToEdit: original.copyWith(id: id)),
        '130',
      );

      final saved = (await tester.runAsync(_rows))!;
      expect(saved, hasLength(1));
      final row = saved.single;
      expect(row['id'], id);
      expect(row['amount'], 130);
      expect(row['is_secret'], 1);
      expect(row['is_recurring'], 1);
      expect(row['goal_id'], 4);
      expect(row['goal_amount'], 10);
      expect(row['date'], original.date.toIso8601String());
    },
  );

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(app(screen));
    await tester.tap(find.text('abrir'));
    await settleDb(tester);
  }

  Transaction gasto(double amount, String note, {int isSecret = 0}) =>
      Transaction(
        amount: amount,
        category: 'Comida',
        type: Transaction.typeExpense,
        date: DateTime.now(),
        isSecret: isSecret,
        note: note,
      );

  testWidgets('Movimientos muestra lo anotado y nunca lo de la Bóveda', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await TransactionController.addTransaction(gasto(10, 'pan'));
      await TransactionController.addTransaction(
        gasto(99, 'secreto', isSecret: 1),
      );
    });

    await open(tester, const MovementsScreen());

    expect(find.text('pan'), findsOneWidget);
    expect(find.text('secreto'), findsNothing);
  });

  testWidgets('Pagos fijos muestra el pago fijo y el plan de cuotas', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.runAsync(() async {
      await TransactionController.addRecurringTransaction(
        gasto(15, 'Netflix'),
        'monthly',
      );
      await TransactionController.addInstallmentPurchase(
        gasto(300, 'Heladera'),
        installments: 3,
        firstDate: DateTime(now.year, now.month + 1, 5),
      );
    });

    await open(tester, const RecurringScreen());

    final l10n = AppLocaleController.instance;
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Heladera'), findsOneWidget);
    expect(
      find.textContaining(
        l10n.text('installments_progress', {'k': '1', 'n': '3'}),
      ),
      findsOneWidget,
    );
  });
}

Future<List<Map<String, Object?>>> _rows() async {
  final db = await DatabaseHelper.instance.database;
  return db.query('transactions');
}
