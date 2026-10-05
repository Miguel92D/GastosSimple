// Actualizar desde la 1.1.8 (chat 05, P-01): no sabemos si la base de la
// 1.1.8 publicada es la 12, 13, 14, 15 o 16. Se arma una base con el esquema
// exacto de cada una (el de la 12 sale de git, commit e1464ef), con datos, y
// se abre con la app de hoy. Nada se pierde, y las migraciones pueden correr
// dos veces (D-004). Usa SQLite en archivo temporal (D-014), porque una base
// en memoria se pierde al cerrarla.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/money.dart';
import 'package:gastos_simple/database/database_helper.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

const _versionActual = 16;

/// Columnas de `recurring_transactions` que agregó cada versión.
const _columnasPagosFijos = {
  13: ['is_secret INTEGER DEFAULT 0', 'anchor_day INTEGER'],
  14: ['installments_total INTEGER', 'installments_paid INTEGER'],
  15: ['installments_total_amount REAL'],
};

/// Esquema de la base en la versión [v] (12 a 16).
Future<void> _crearEsquema(Database db, int v) async {
  await db.execute('''
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,
  date TEXT NOT NULL,
  is_secret INTEGER DEFAULT 0,
  note TEXT,
  is_recurring INTEGER DEFAULT 0,
  goal_id INTEGER,
  goal_amount REAL
)''');
  await db.execute('''
CREATE TABLE goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  saved_amount REAL NOT NULL DEFAULT 0,
  target_date TEXT,
  icon TEXT,
  created_at TEXT
)''');
  final extra = [
    for (final entry in _columnasPagosFijos.entries)
      if (entry.key <= v) ...entry.value,
  ];
  await db.execute('''
CREATE TABLE recurring_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,
  note TEXT,
  frequency TEXT NOT NULL,
  next_date TEXT NOT NULL${extra.map((c) => ',\n  $c').join()}
)''');
  await db.execute('''
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  monto_total REAL NOT NULL,
  monto_pagado REAL NOT NULL DEFAULT 0,
  pago_minimo REAL NOT NULL,
  tasa_interes REAL,
  fecha_vencimiento TEXT NOT NULL,
  dia_cierre INTEGER,
  cuotas_totales INTEGER,
  cuotas_pagadas INTEGER
)''');
}

/// Datos como los dejaría la 1.1.8: montos con restos de punto flotante,
/// un movimiento de la Bóveda, meta, deuda en cuotas y un pago fijo.
Future<void> _cargarDatos(Database db, int v) async {
  // Desde la 16 toda escritura pasa por Money.round (D-005).
  double m(double x) => v >= 16 ? Money.round(x) : x;
  await db.insert('transactions', {
    'id': 1,
    'amount': m(1530.0000000002),
    'category': 'Comida',
    'type': 'gasto',
    'date': '2026-09-01T10:00:00.000',
    'note': 'súper',
  });
  await db.insert('transactions', {
    'id': 2,
    'amount': 250000.0,
    'category': 'Sueldo',
    'type': 'ingreso',
    'date': '2026-09-01T09:00:00.000',
  });
  await db.insert('transactions', {
    'id': 3,
    'amount': 5000.0,
    'category': 'Regalo',
    'type': 'gasto',
    'date': '2026-09-02T12:00:00.000',
    'is_secret': 1,
  });
  await db.insert('transactions', {
    'id': 4,
    'amount': 300.0,
    'category': 'Ahorro',
    'type': 'gasto',
    'date': '2026-09-03T12:00:00.000',
    'goal_id': 1,
    'goal_amount': m(300.004),
  });
  await db.insert('goals', {
    'id': 1,
    'name': 'Auto',
    'target_amount': 1000000.0,
    'saved_amount': m(12500.499999999),
    'target_date': '2027-06-01T00:00:00.000',
    'icon': '🚗',
    'created_at': '2026-01-02T00:00:00.000',
  });
  await db.insert('debts', {
    'id': 1,
    'nombre': 'Tarjeta',
    'monto_total': 80000.0,
    'monto_pagado': m(20000.000000001),
    'pago_minimo': 5000.0,
    'tasa_interes': 4.5,
    'fecha_vencimiento': '10/10/2026',
    'dia_cierre': 28,
    'cuotas_totales': 6,
    'cuotas_pagadas': 2,
  });
  await db.insert('recurring_transactions', {
    'id': 1,
    'amount': 30000.0,
    'category': 'Alquiler',
    'type': 'gasto',
    'frequency': 'monthly',
    'next_date': '2099-01-05T00:00:00.000',
    if (v >= 13) 'is_secret': 0,
    if (v >= 13) 'anchor_day': 5,
  });
}

/// Todo lo que el usuario ve, leído con el código de la app.
Future<Map<String, Object?>> _loQueVeElUsuario() async {
  final h = DatabaseHelper.instance;
  return {
    'normales': [for (final t in await h.getAllTransactions()) t.toMap()],
    'boveda': [for (final t in await h.getSecretTransactions()) t.toMap()],
    'metas': [for (final g in await h.getGoals()) g.toMap()],
    'deudas': [for (final d in await h.getDebts()) d.toMap()],
    'pagosFijos': await h.getRecurringTransactions(),
  };
}

/// Versión de la base que tiene abierta la app (abrir el mismo archivo con
/// otra conexión la cerraría: sqflite reusa una sola por archivo).
Future<int> _versionDeLaApp() async =>
    (await DatabaseHelper.instance.database).getVersion();

/// Simula una base que dice ser [v] (para volver a correr las migraciones).
Future<void> _marcarVersion(String path, int v) async {
  final db = await databaseFactoryFfi.openDatabase(path);
  await db.setVersion(v);
  await db.close();
}

late Directory _carpeta;

Future<String> _baseDeLa118(int v) async {
  final path = p.join(_carpeta.path, 'simple_wallet_v$v.db');
  await DatabaseHelper.resetForTesting();
  if (File(path).existsSync()) File(path).deleteSync();
  final db = await databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: v,
      onCreate: (db, _) => _crearEsquema(db, v),
    ),
  );
  await _cargarDatos(db, v);
  await db.close();
  return path;
}

Future<void> _abrirConLaAppDeHoy(String path) async {
  await DatabaseHelper.resetForTesting();
  DatabaseHelper.pathOverride = path;
  await DatabaseHelper.instance.database;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _carpeta = Directory.systemTemp.createTempSync('simple_upgrade_');
  });

  tearDown(DatabaseHelper.resetForTesting);

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
    _carpeta.deleteSync(recursive: true);
  });

  for (final v in [12, 13, 14, 15, 16]) {
    group('desde la base $v', () {
      test('no se pierde nada y los montos quedan a centavos', () async {
        final path = await _baseDeLa118(v);
        await _abrirConLaAppDeHoy(path);

        expect(await _versionDeLaApp(), _versionActual);
        final h = DatabaseHelper.instance;

        final normales = await h.getAllTransactions();
        expect(normales.map((t) => t.category).toSet(), {
          'Comida',
          'Sueldo',
          'Ahorro',
        });
        final comida = normales.firstWhere((t) => t.category == 'Comida');
        expect(comida.amount, 1530.0);
        expect(comida.note, 'súper');
        final ahorro = normales.firstWhere((t) => t.category == 'Ahorro');
        expect(ahorro.goalId, 1);
        expect(ahorro.goalAmount, 300.0);

        final boveda = await h.getSecretTransactions();
        expect(boveda.single.category, 'Regalo');

        final meta = (await h.getGoals()).single;
        expect(meta.name, 'Auto');
        expect(meta.currentAmount, 12500.5);

        final deuda = (await h.getDebts()).single;
        expect(deuda.nombre, 'Tarjeta');
        expect(deuda.montoPagado, 20000.0);
        expect(deuda.cuotasTotales, 6);
        expect(deuda.cuotasPagadas, 2);

        final pago = (await h.getRecurringTransactions()).single;
        expect(pago['category'], 'Alquiler');
        expect(pago['amount'], 30000.0);
        expect(pago['is_secret'], 0);
      });

      test('después se puede usar todo (cuotas incluidas)', () async {
        final path = await _baseDeLa118(v);
        await _abrirConLaAppDeHoy(path);
        final h = DatabaseHelper.instance;

        await h.insertInstallmentPlan(
          perInstallment: 333.33,
          totalAmount: 1000,
          count: 3,
          firstDate: DateTime(2020, 1, 15),
          category: 'Compras',
          type: Transaction.typeExpense,
          isSecret: 0,
        );
        await h.insertRecurringTransaction(
          Transaction(
            amount: 800,
            category: 'Gimnasio',
            type: Transaction.typeExpense,
            date: DateTime(2099, 1, 10),
            isSecret: 1,
          ),
          'monthly',
        );
        await h.processRecurringTransactions();

        final cuotas = (await h.getAllTransactions())
            .where((t) => t.category == 'Compras')
            .map((t) => t.amount)
            .toList();
        expect(cuotas..sort(), [333.33, 333.33, 333.34]);
        expect(
          (await h.getRecurringTransactions(isSecret: true)).single['category'],
          'Gimnasio',
        );
      });

      test(
        'las migraciones pueden correr dos veces sin cambiar nada',
        () async {
          final path = await _baseDeLa118(v);
          await _abrirConLaAppDeHoy(path);
          final unaVez = await _loQueVeElUsuario();

          await DatabaseHelper.resetForTesting();
          await _marcarVersion(path, v);
          await _abrirConLaAppDeHoy(path);

          expect(await _loQueVeElUsuario(), unaVez);
          expect(await _versionDeLaApp(), _versionActual);
        },
      );
    });
  }

  test('base de hoy marcada como 12: repetir 13–16 no rompe nada', () async {
    final path = await _baseDeLa118(16);
    await _abrirConLaAppDeHoy(path);
    final antes = await _loQueVeElUsuario();

    for (var vez = 0; vez < 2; vez++) {
      await DatabaseHelper.resetForTesting();
      await _marcarVersion(path, 12);
      await _abrirConLaAppDeHoy(path);
      expect(await _loQueVeElUsuario(), antes, reason: 'repetición ${vez + 1}');
    }
  });

  test('una base más nueva (17) se abre sin borrar nada', () async {
    final path = await _baseDeLa118(16);
    await _marcarVersion(path, 17);

    await _abrirConLaAppDeHoy(path);

    final h = DatabaseHelper.instance;
    expect(await h.getAllTransactions(), hasLength(3));
    expect(await h.getSecretTransactions(), hasLength(1));
    expect(await h.getGoals(), hasLength(1));
    expect(await h.getDebts(), hasLength(1));
  });

  test('un movimiento con is_secret vacío vuelve a verse', () async {
    final path = await _baseDeLa118(12);
    final db = await databaseFactoryFfi.openDatabase(path);
    await db.rawUpdate('UPDATE transactions SET is_secret = NULL WHERE id = 2');
    await db.close();

    await _abrirConLaAppDeHoy(path);

    final normales = await DatabaseHelper.instance.getAllTransactions();
    expect(normales.map((t) => t.category), contains('Sueldo'));
  });
}
