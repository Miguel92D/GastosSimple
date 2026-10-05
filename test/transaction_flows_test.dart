// Flujos del núcleo contra una base SQLite real en memoria (sqflite_common_ffi):
// anotar, editar, ver, pago fijo y cuotas (chat 02).
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/database/database_helper.dart';
import 'package:gastos_simple/features/transactions/controllers/transaction_controller.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

Transaction _gasto(
  double amount, {
  DateTime? date,
  int isSecret = 0,
  String category = 'Comida',
  String? note,
}) => Transaction(
  amount: amount,
  category: category,
  type: Transaction.typeExpense,
  date: date ?? DateTime.now(),
  isSecret: isSecret,
  note: note,
);

Future<List<Map<String, Object?>>> _rows(String table) async {
  final db = await DatabaseHelper.instance.database;
  return db.query(table, orderBy: 'id ASC');
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
  });

  setUp(DatabaseHelper.resetForTesting);
  tearDownAll(DatabaseHelper.resetForTesting);

  // Primer día de hace [monthsAgo] meses, a medianoche: siempre en el pasado.
  DateTime firstOfMonthAgo(int monthsAgo) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - monthsAgo, 1);
  }

  group('Anotar', () {
    test(
      'guarda el gasto redondeado a centavos y aparece en el historial',
      () async {
        await TransactionController.addTransaction(_gasto(0.1 + 0.2));
        await TransactionController.addTransaction(
          Transaction(
            amount: 1500,
            category: 'Salario',
            type: 'income', // tipo viejo en inglés: se normaliza
            date: DateTime.now(),
          ),
        );

        final history = await TransactionController.getNormalHistory();
        expect(history, hasLength(2));
        final gasto = history.firstWhere((t) => t.isExpense);
        expect(gasto.amount, 0.3);
        expect(history.firstWhere((t) => t.isIncome).type, 'ingreso');
      },
    );

    test('un gasto de la Bóveda no aparece en el historial normal', () async {
      await TransactionController.addTransaction(_gasto(50, isSecret: 1));
      await TransactionController.addTransaction(_gasto(20));

      final normal = await TransactionController.getNormalHistory();
      final vault = await TransactionController.getVaultHistory();
      expect(normal.map((t) => t.amount), [20]);
      expect(vault.map((t) => t.amount), [50]);
    });
  });

  group('Editar', () {
    test('cambia monto, categoría y nota sin duplicar', () async {
      await TransactionController.addTransaction(_gasto(100, note: 'súper'));
      final original = (await TransactionController.getNormalHistory()).single;

      await TransactionController.updateTransaction(
        original.copyWith(amount: 120.555, category: 'Ocio', note: 'cine'),
      );

      final edited = (await TransactionController.getNormalHistory()).single;
      expect(edited.id, original.id);
      expect(edited.amount, 120.56);
      expect(edited.category, 'Ocio');
      expect(edited.note, 'cine');
    });

    test(
      'editar un movimiento de la Bóveda conserva isSecret (§7.7)',
      () async {
        await TransactionController.addTransaction(_gasto(80, isSecret: 1));
        final secret = (await TransactionController.getVaultHistory()).single;

        await TransactionController.updateTransaction(
          secret.copyWith(amount: 90),
        );

        expect(await TransactionController.getNormalHistory(), isEmpty);
        expect(
          (await TransactionController.getVaultHistory()).single.amount,
          90,
        );
      },
    );

    test('editar conserva la marca de pago fijo y la meta', () async {
      await TransactionController.addTransaction(
        Transaction(
          amount: 10,
          category: 'Suscripciones',
          type: Transaction.typeExpense,
          date: DateTime.now(),
          isRecurring: true,
          goalId: 7,
        ),
      );
      final original = (await TransactionController.getNormalHistory()).single;
      expect(original.goalAmount, isNull);

      await TransactionController.updateTransaction(
        original.copyWith(amount: 12),
      );

      final row = (await _rows('transactions')).single;
      expect(row['is_recurring'], 1);
      expect(row['goal_id'], 7);
      expect(row['goal_amount'], isNull);
    });
  });

  group('Ver', () {
    test('historial ordenado del más nuevo al más viejo', () async {
      final now = DateTime.now();
      await TransactionController.addTransaction(
        _gasto(1, date: now.subtract(const Duration(days: 2))),
      );
      await TransactionController.addTransaction(_gasto(3, date: now));
      await TransactionController.addTransaction(
        _gasto(2, date: now.subtract(const Duration(days: 1))),
      );

      final history = await TransactionController.getNormalHistory();
      expect(history.map((t) => t.amount), [3, 2, 1]);
    });

    test('borrar y deshacer devuelve el mismo movimiento', () async {
      await TransactionController.addTransaction(_gasto(42, note: 'nafta'));
      final mov = (await TransactionController.getNormalHistory()).single;

      await TransactionController.deleteTransaction(mov.id!);
      expect(await TransactionController.getNormalHistory(), isEmpty);

      await TransactionController.restoreDeleted(mov);
      final back = (await TransactionController.getNormalHistory()).single;
      expect(back.id, mov.id);
      expect(back.note, 'nafta');
    });
  });

  group('Pago fijo', () {
    test('mensual con fecha pasada genera las ocurrencias vencidas', () async {
      final start = firstOfMonthAgo(2);
      final mov = _gasto(
        9.99,
        date: start,
        category: 'Suscripciones',
      ).copyWith(isRecurring: true);

      await TransactionController.addTransaction(mov);
      await TransactionController.addRecurringTransaction(mov, 'monthly');

      // Original + el día 1 de cada uno de los dos meses siguientes.
      final history = await TransactionController.getNormalHistory();
      expect(history, hasLength(3));
      expect(history.every((t) => t.isRecurring), isTrue);
      expect(history.map((t) => t.amount).toSet(), {9.99});
      expect(history.map((t) => t.date.day).toSet(), {1});

      final plan = (await TransactionController.getRecurringPayments()).single;
      expect(plan.nextDate, DateTime(start.year, start.month + 3, 1));
      expect(plan.isInstallment, isFalse);
    });

    test('respeta el día 31 en meses cortos (RecurrenceSchedule)', () async {
      // Pago del 31/01: debe quedar programado para el 28/02 y volver al 31.
      final mov = _gasto(100, date: DateTime(2099, 1, 31));
      await TransactionController.addRecurringTransaction(mov, 'monthly');

      final plan = (await TransactionController.getRecurringPayments()).single;
      expect(plan.nextDate, DateTime(2099, 2, 28));
      expect((await _rows('recurring_transactions')).single['anchor_day'], 31);
    });

    test('un pago fijo de la Bóveda genera movimientos secretos', () async {
      final mov = _gasto(5, date: firstOfMonthAgo(1), isSecret: 1);
      await TransactionController.addRecurringTransaction(mov, 'monthly');

      expect(await TransactionController.getNormalHistory(), isEmpty);
      expect(await TransactionController.getVaultHistory(), isNotEmpty);
      expect(
        await TransactionController.getRecurringPayments(isVault: true),
        hasLength(1),
      );
    });

    test('cancelar conserva los movimientos ya generados', () async {
      final mov = _gasto(5, date: firstOfMonthAgo(1));
      await TransactionController.addRecurringTransaction(mov, 'monthly');
      final plan = (await TransactionController.getRecurringPayments()).single;

      await TransactionController.cancelRecurring(plan.id);

      expect(await TransactionController.getRecurringPayments(), isEmpty);
      expect(await TransactionController.getNormalHistory(), hasLength(1));
    });
  });

  group('Cuotas', () {
    test(
      '100 en 3 cuotas ya vencidas: 33,33 + 33,33 + 33,34 y el plan se borra',
      () async {
        await TransactionController.addInstallmentPurchase(
          _gasto(100, note: 'Heladera'),
          installments: 3,
          firstDate: firstOfMonthAgo(2),
        );

        final history = await TransactionController.getNormalHistory();
        expect(history, hasLength(3));
        final byDate = history.reversed.toList();
        expect(byDate.map((t) => t.amount), [33.33, 33.33, 33.34]);
        expect(byDate.map((t) => t.note), [
          'Heladera (1/3)',
          'Heladera (2/3)',
          'Heladera (3/3)',
        ]);
        expect(await TransactionController.getRecurringPayments(), isEmpty);
      },
    );

    test('primera cuota en el futuro: no se crea ningún movimiento', () async {
      final now = DateTime.now();
      await TransactionController.addInstallmentPurchase(
        _gasto(600),
        installments: 6,
        firstDate: DateTime(now.year, now.month + 1, 10),
      );

      expect(await TransactionController.getNormalHistory(), isEmpty);
      final plan = (await TransactionController.getRecurringPayments()).single;
      expect(plan.installmentsTotal, 6);
      expect(plan.installmentsPaid, 0);
      expect(plan.amount, 100);
      expect(plan.remainingAmount, 600);
    });

    test(
      'plan a medias: registra solo las vencidas y lleva la cuenta',
      () async {
        await TransactionController.addInstallmentPurchase(
          _gasto(100),
          installments: 3,
          firstDate: firstOfMonthAgo(1),
        );

        expect(await TransactionController.getNormalHistory(), hasLength(2));
        final plan =
            (await TransactionController.getRecurringPayments()).single;
        expect(plan.installmentsPaid, 2);
        expect(plan.nextInstallment, 3);
        expect(plan.remainingAmount, 33.34);
      },
    );

    test('cambiar el monto de la cuota recalcula el total del plan', () async {
      final now = DateTime.now();
      await TransactionController.addInstallmentPurchase(
        _gasto(100),
        installments: 3,
        firstDate: DateTime(now.year, now.month + 1, 10),
      );
      final plan = (await TransactionController.getRecurringPayments()).single;

      await TransactionController.updateRecurringAmount(plan.id, 40);

      final updated =
          (await TransactionController.getRecurringPayments()).single;
      expect(updated.amount, 40);
      expect(updated.installmentsTotalAmount, 120);
      expect(updated.remainingAmount, 120);
    });
  });
}
