// Respaldo (chat 05): exportar y restaurar ida y vuelta sin perder ni
// duplicar nada, y la Bóveda solo si el usuario la incluye (Especificación
// §7.5 y §8). Usa SQLite en memoria (D-014).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/database/database_helper.dart';
import 'package:gastos_simple/features/debts/models/debt.dart';
import 'package:gastos_simple/features/goals/models/goal.dart';
import 'package:gastos_simple/features/settings/controllers/backup_controller.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

const _tables = ['transactions', 'goals', 'debts', 'recurring_transactions'];

Future<Database> get _db => DatabaseHelper.instance.database;

/// Todo lo que hay en la base, sin ids y ordenado: dos teléfonos con los
/// mismos datos dan la misma foto aunque los ids sean otros.
Future<Map<String, List<String>>> _foto() async {
  final db = await _db;
  return {
    for (final t in _tables)
      t: [
        for (final row in await db.query(t))
          jsonEncode(Map.of(row)..remove('id')),
      ]..sort(),
  };
}

Future<int> _cuenta(String table) async =>
    (await (await _db).query(table)).length;

Transaction _mov(
  double amount,
  String category, {
  String type = Transaction.typeExpense,
  int isSecret = 0,
  String? note,
  DateTime? date,
}) => Transaction(
  amount: amount,
  category: category,
  type: type,
  date: date ?? DateTime(2026, 9, 1, 10, 30, 15, 123),
  isSecret: isSecret,
  note: note,
);

/// Un teléfono con un poco de todo: movimientos normales y de la Bóveda,
/// meta, deuda, pago fijo, plan de cuotas y un pago fijo de la Bóveda.
Future<void> _llenarTelefono() async {
  final h = DatabaseHelper.instance;
  await h.insertTransaction(_mov(1530.25, 'Comida', note: 'súper'));
  await h.insertTransaction(
    _mov(250000, 'Sueldo', type: Transaction.typeIncome),
  );
  await h.insertTransaction(
    _mov(99.99, 'Transporte', date: DateTime(2026, 8, 31)),
  );
  await h.insertTransaction(_mov(5000, 'Regalo', isSecret: 1, note: 'secreto'));
  await h.insertGoal(
    Goal(
      name: 'Auto',
      targetAmount: 1000000,
      currentAmount: 12500.5,
      targetDate: DateTime(2027, 6, 1),
      icon: '🚗',
      createdAt: DateTime(2026, 1, 2),
    ),
  );
  await h.insertDebt(
    Debt(
      nombre: 'Tarjeta',
      montoTotal: 80000,
      montoPagado: 20000,
      pagoMinimo: 5000,
      tasaInteres: 4.5,
      fechaVencimiento: '10/10/2026',
      diaCierre: '28',
      cuotasTotales: 6,
      cuotasPagadas: 2,
    ),
  );
  await h.insertRecurringTransaction(
    _mov(30000, 'Alquiler', date: DateTime(2026, 9, 5)),
    'monthly',
  );
  await h.insertRecurringTransaction(
    _mov(800, 'Gimnasio', isSecret: 1, date: DateTime(2026, 9, 10)),
    'monthly',
  );
  await h.insertInstallmentPlan(
    perInstallment: 333.33,
    totalAmount: 1000,
    count: 3,
    firstDate: DateTime(2026, 10, 15),
    category: 'Compras',
    type: Transaction.typeExpense,
    isSecret: 0,
  );
}

/// Pasa al "teléfono nuevo": una base vacía.
Future<void> _telefonoNuevo() => DatabaseHelper.resetForTesting();

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
  });

  setUp(DatabaseHelper.resetForTesting);
  tearDownAll(DatabaseHelper.resetForTesting);

  test('con la Bóveda: el teléfono nuevo queda igual al viejo', () async {
    await _llenarTelefono();
    final antes = await _foto();
    final archivo = await BackupController.buildBackupJson(includeVault: true);

    await _telefonoNuevo();
    await BackupController.restoreBackupJson(archivo);

    expect(await _foto(), antes);
    expect(await _cuenta('transactions'), 4);
    expect(await _cuenta('recurring_transactions'), 3);
  });

  test('sin la Bóveda: nada secreto sale en el archivo', () async {
    await _llenarTelefono();
    final archivo = await BackupController.buildBackupJson();

    expect(archivo, isNot(contains('secreto')));
    expect(archivo, isNot(contains('Gimnasio')));
    final data = jsonDecode(archivo) as Map<String, dynamic>;
    expect(data['includes_vault'], isFalse);

    await _telefonoNuevo();
    await BackupController.restoreBackupJson(archivo);

    final db = await _db;
    expect(await db.query('transactions', where: 'is_secret = 1'), isEmpty);
    expect(
      await db.query('recurring_transactions', where: 'is_secret = 1'),
      isEmpty,
    );
    // Todo lo normal llegó.
    expect(await _cuenta('transactions'), 3);
    expect(await _cuenta('recurring_transactions'), 2);
    expect(await _cuenta('goals'), 1);
    expect(await _cuenta('debts'), 1);
  });

  test('hay Bóveda para preguntar solo si hay algo secreto', () async {
    expect(await BackupController.hasVaultData(), isFalse);
    await DatabaseHelper.instance.insertRecurringTransaction(
      _mov(800, 'Gimnasio', isSecret: 1),
      'monthly',
    );
    expect(await BackupController.hasVaultData(), isTrue);
  });

  test('restaurar dos veces el mismo archivo no duplica nada', () async {
    await _llenarTelefono();
    final archivo = await BackupController.buildBackupJson(includeVault: true);
    await _telefonoNuevo();

    await BackupController.restoreBackupJson(archivo);
    final unaVez = await _foto();
    await BackupController.restoreBackupJson(archivo);
    await BackupController.restoreBackupJson(archivo);

    expect(await _foto(), unaVez);
  });

  test('restaurar en el mismo teléfono no duplica ni pierde nada', () async {
    await _llenarTelefono();
    final antes = await _foto();
    final archivo = await BackupController.buildBackupJson(includeVault: true);

    await BackupController.restoreBackupJson(archivo);

    expect(await _foto(), antes);
  });

  test(
    'teléfono con sus propios datos: se suman los dos, y repetir no duplica',
    () async {
      await _llenarTelefono();
      final archivo = await BackupController.buildBackupJson(
        includeVault: true,
      );

      // El teléfono nuevo ya tiene movimientos propios que ocupan los
      // mismos ids que trae el archivo.
      await _telefonoNuevo();
      final h = DatabaseHelper.instance;
      for (var i = 0; i < 4; i++) {
        await h.insertTransaction(
          _mov(10.0 + i, 'Café', date: DateTime(2026, 9, 20 + i)),
        );
      }

      await BackupController.restoreBackupJson(archivo);
      expect(await _cuenta('transactions'), 8);
      final propios = await (await _db).query(
        'transactions',
        where: 'category = ?',
        whereArgs: ['Café'],
      );
      expect(propios, hasLength(4), reason: 'los datos propios no se pisan');

      final despues = await _foto();
      await BackupController.restoreBackupJson(archivo);
      expect(await _foto(), despues);
    },
  );

  test('un tipo viejo escrito distinto ("Gasto") no se duplica', () async {
    final db = await _db;
    await db.insert('transactions', {
      'amount': 1500.0,
      'category': 'Comida',
      'type': 'Gasto',
      'date': '2026-09-01T10:00:00.000',
      'is_secret': 0,
    });
    final archivo = await BackupController.buildBackupJson();

    await BackupController.restoreBackupJson(archivo);

    expect(await _cuenta('transactions'), 1);
  });

  test('dos movimientos iguales en el archivo llegan los dos', () async {
    final h = DatabaseHelper.instance;
    await h.insertTransaction(_mov(100, 'Café'));
    await h.insertTransaction(_mov(100, 'Café'));
    final archivo = await BackupController.buildBackupJson();

    await _telefonoNuevo();
    await BackupController.restoreBackupJson(archivo);
    expect(await _cuenta('transactions'), 2);

    await BackupController.restoreBackupJson(archivo);
    expect(await _cuenta('transactions'), 2);
  });

  test('un archivo roto no escribe nada', () async {
    await _llenarTelefono();
    final antes = await _foto();
    final data =
        jsonDecode(await BackupController.buildBackupJson())
            as Map<String, dynamic>;
    // El último pago fijo trae una fecha imposible.
    (data['recurring_transactions'] as List).add({
      'id': 99,
      'amount': 1,
      'category': 'X',
      'type': 'gasto',
      'frequency': 'monthly',
      'next_date': 'no-es-fecha',
    });

    await expectLater(
      BackupController.restoreBackupJson(jsonEncode(data)),
      throwsA(isA<FormatException>()),
    );
    expect(await _foto(), antes);
  });

  test('los respaldos viejos (lista plana v1) se siguen leyendo', () async {
    final v1 = jsonEncode([
      {
        'id': 1,
        'monto': 700,
        'categoria': 'Comida',
        'tipo': 'gasto',
        'fecha': '2025-12-24T20:00:00.000',
        'nota': 'cena',
      },
    ]);

    await BackupController.restoreBackupJson(v1);

    final rows = await (await _db).query('transactions');
    expect(rows, hasLength(1));
    expect(rows.single['amount'], 700);
    expect(rows.single['note'], 'cena');
    expect(rows.single['is_secret'], 0);
  });
}
