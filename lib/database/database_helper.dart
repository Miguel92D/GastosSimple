import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../features/transactions/models/transaction.dart' as model;
import '../core/error/exceptions.dart';
import '../features/goals/models/goal.dart';
import '../features/debts/models/debt.dart';
import '../core/utils/recurrence_schedule.dart';
import '../core/utils/backup_merge.dart';
import '../core/utils/installment_plan.dart';
import '../core/utils/money.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Solo para tests: ruta de la base (ej. `inMemoryDatabasePath`) en vez
  /// del archivo real del teléfono.
  @visibleForTesting
  static String? pathOverride;

  /// Solo para tests: cierra la base para empezar la próxima limpia.
  @visibleForTesting
  static Future<void> resetForTesting() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('simple_wallet.db'); // Consistent name
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = pathOverride ?? join(await getDatabasesPath(), filePath);

    return await openDatabase(
      path,
      version: 16, // 14: cuotas · 15: total del plan · 16: montos a centavos
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _repairOnOpen,
    );
  }

  /// Arreglos que corren en cada apertura (baratos y repetibles, D-004).
  /// Un movimiento con `is_secret` vacío no aparecería ni en la lista normal
  /// (`= 0`) ni en la Bóveda (`= 1`): para el usuario sería un dato perdido.
  /// Pasa a ser normal, que es lo que valía antes de existir la Bóveda.
  Future<void> _repairOnOpen(Database db) async {
    await _tryExecute(
      db,
      'UPDATE transactions SET is_secret = 0 WHERE is_secret IS NULL',
    );
    await _tryExecute(
      db,
      'UPDATE recurring_transactions SET is_secret = 0 WHERE is_secret IS NULL',
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const numType = 'REAL NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  amount $numType,
  category $textType,
  type $textType,
  date $textType,
  is_secret INTEGER DEFAULT 0,
  note TEXT,
  is_recurring INTEGER DEFAULT 0,
  goal_id INTEGER,
  goal_amount REAL
)
''');

    await db.execute('''
CREATE TABLE goals (
  id $idType,
  name $textType,
  target_amount $numType,
  saved_amount $numType DEFAULT 0,
  target_date TEXT,
  icon TEXT,
  created_at TEXT
)
''');

    await db.execute('''
CREATE TABLE recurring_transactions (
  id $idType,
  amount $numType,
  category $textType,
  type $textType,
  note TEXT,
  frequency $textType,
  next_date $textType,
  is_secret INTEGER DEFAULT 0,
  anchor_day INTEGER,
  installments_total INTEGER,
  installments_paid INTEGER,
  installments_total_amount REAL
)
''');

    await db.execute('''
CREATE TABLE debts (
  id $idType,
  nombre $textType,
  monto_total $numType,
  monto_pagado $numType DEFAULT 0,
  pago_minimo $numType,
  tasa_interes REAL,
  fecha_vencimiento $textType,
  dia_cierre INTEGER,
  cuotas_totales INTEGER,
  cuotas_pagadas INTEGER
)
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE movimientos ADD COLUMN archived INTEGER DEFAULT 0',
        );
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE movimientos ADD COLUMN nota TEXT');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute(
          'ALTER TABLE movimientos ADD COLUMN is_recurring INTEGER DEFAULT 0',
        );
        await db.execute('''
CREATE TABLE recurring_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,
  note TEXT,
  frequency TEXT NOT NULL,
  next_date TEXT NOT NULL
)
''');
      } catch (_) {}
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE movimientos ADD COLUMN goal_id INTEGER');
        await db.execute('ALTER TABLE movimientos ADD COLUMN goal_amount REAL');
        await db.execute('''
CREATE TABLE goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  saved_amount REAL DEFAULT 0
)
''');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      try {
        await db.execute('''
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  monto_total REAL NOT NULL,
  monto_pagado REAL DEFAULT 0,
  pago_minimo REAL NOT NULL,
  tasa_interes REAL,
  fecha_vencimiento TEXT NOT NULL
)
''');
      } catch (_) {}
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE debts ADD COLUMN dia_cierre INTEGER');
      } catch (_) {}
    }
    if (oldVersion < 8) {
      try {
        await db.execute(
          'ALTER TABLE movimientos ADD COLUMN is_secret INTEGER DEFAULT 0',
        );
        await db.execute(
          'UPDATE movimientos SET is_secret = 1 WHERE archived = 1',
        );
      } catch (_) {}
    }
    if (oldVersion < 9) {
      // Major migration to 'transactions' table
      try {
        await db.execute('''
CREATE TABLE IF NOT EXISTS transactions (
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
)
''');
        // Check if old 'movimientos' table exists
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='movimientos'",
        );
        if (tables.isNotEmpty) {
          await db.execute('''
INSERT INTO transactions (id, amount, category, type, date, is_secret, note, is_recurring, goal_id, goal_amount)
SELECT id, monto, categoria, tipo, fecha, is_secret, nota, is_recurring, goal_id, goal_amount FROM movimientos
''');
          // Optional: Drop old table
          // await db.execute('DROP TABLE movimientos');
        }
      } catch (e) {
        debugPrint('Migration error: $e');
      }
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE goals ADD COLUMN created_at TEXT');
      } catch (_) {}
    }
    if (oldVersion < 12) {
      // Cada ALTER va por separado: si uno falla (columna ya existente)
      // el otro igual se aplica.
      await _tryExecute(
        db,
        'ALTER TABLE debts ADD COLUMN cuotas_totales INTEGER',
      );
      await _tryExecute(
        db,
        'ALTER TABLE debts ADD COLUMN cuotas_pagadas INTEGER',
      );
    }
    if (oldVersion < 13) {
      // Las recurrencias creadas en la Bóveda deben seguir siendo secretas.
      await _tryExecute(
        db,
        'ALTER TABLE recurring_transactions ADD COLUMN is_secret INTEGER DEFAULT 0',
      );
      await _tryExecute(
        db,
        'ALTER TABLE recurring_transactions ADD COLUMN anchor_day INTEGER',
      );
    }
    if (oldVersion < 14) {
      // Compras en cuotas: total de cuotas y cuántas ya se registraron.
      await _tryExecute(
        db,
        'ALTER TABLE recurring_transactions ADD COLUMN installments_total INTEGER',
      );
      await _tryExecute(
        db,
        'ALTER TABLE recurring_transactions ADD COLUMN installments_paid INTEGER',
      );
    }
    if (oldVersion < 15) {
      // Total del plan: la última cuota absorbe la diferencia de redondeo.
      await _tryExecute(
        db,
        'ALTER TABLE recurring_transactions ADD COLUMN installments_total_amount REAL',
      );
    }
    if (oldVersion < 16) {
      // Limpieza única: redondea a centavos los montos ya guardados (restos
      // de punto flotante como 1530.0000000002).
      for (final sql in const [
        'UPDATE transactions SET amount = ROUND(amount, 2), goal_amount = ROUND(goal_amount, 2)',
        'UPDATE goals SET target_amount = ROUND(target_amount, 2), saved_amount = ROUND(saved_amount, 2)',
        'UPDATE debts SET monto_total = ROUND(monto_total, 2), monto_pagado = ROUND(monto_pagado, 2), pago_minimo = ROUND(pago_minimo, 2)',
        'UPDATE recurring_transactions SET amount = ROUND(amount, 2), installments_total_amount = ROUND(installments_total_amount, 2)',
      ]) {
        await _tryExecute(db, sql);
      }
    }
  }

  Future<void> _tryExecute(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (e) {
      debugPrint('Migration step skipped ($sql): $e');
    }
  }

  Future<int> insertTransaction(model.Transaction mov) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('transactions', mov.toMap());
    } catch (e, _) {
      debugPrint('DB Error (insertTransaction): $e');
      throw DatabaseException('Operación fallida en insertTransaction', e);
    }
  }

  /// Inserta una transacción de un backup conservando su id original.
  /// Si ya existe una fila con ese id se reemplaza, lo que hace que
  /// restaurar el mismo backup varias veces sea idempotente (sin duplicados
  /// ni errores de clave primaria).
  Future<int> restoreTransaction(model.Transaction mov) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert(
        'transactions',
        mov.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, _) {
      debugPrint('DB Error (restoreTransaction): $e');
      throw DatabaseException('Operación fallida en restoreTransaction', e);
    }
  }

  Future<model.Transaction?> getTransactionById(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return model.Transaction.fromMap(result.first);
      }
    } catch (e, _) {
      debugPrint('DB Error (getTransactionById): $e');
      throw DatabaseException('Operación fallida en getTransactionById', e);
    }
    return null;
  }

  Future<int> insertRecurringTransaction(
    model.Transaction mov,
    String frequency,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final anchorDay = mov.date.day;
      final nextDate = RecurrenceSchedule.next(
        mov.date,
        frequency,
        anchorDay: anchorDay,
      );

      return await db.insert('recurring_transactions', {
        'amount': Money.round(mov.amount),
        'category': mov.category,
        'type': mov.type,
        'note': mov.note,
        'frequency': frequency,
        'next_date': nextDate.toIso8601String(),
        // Regla de Oro #6: una recurrencia de la Bóveda genera movimientos
        // secretos, nunca normales.
        'is_secret': mov.isSecret,
        'anchor_day': anchorDay,
      });
    } catch (e, _) {
      debugPrint('DB Error (insertRecurringTransaction): $e');
      throw DatabaseException(
        'Operación fallida en insertRecurringTransaction',
        e,
      );
    }
  }

  /// Plan de cuotas: ninguna cuota se registra acá. La primera vence en
  /// [firstDate] y todas las genera [processRecurringTransactions] cuando
  /// llega su fecha (nunca se crean movimientos con fecha futura).
  Future<int> insertInstallmentPlan({
    required double perInstallment,
    required double totalAmount,
    required int count,
    required DateTime firstDate,
    required String category,
    required String type,
    required int isSecret,
    String? baseNote,
    int? anchorDay,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('recurring_transactions', {
        'amount': Money.round(perInstallment),
        'category': category,
        'type': type,
        'note': baseNote,
        'frequency': RecurrenceSchedule.monthly,
        'next_date': firstDate.toIso8601String(),
        'is_secret': isSecret,
        // Con tarjeta, el ancla es su día de vencimiento (un vencimiento
        // el 31 cae el 30/11 pero vuelve al 31/12).
        'anchor_day': anchorDay ?? firstDate.day,
        'installments_total': count,
        'installments_paid': 0,
        'installments_total_amount': Money.round(totalAmount),
      });
    } catch (e, _) {
      debugPrint('DB Error (insertInstallmentPlan): $e');
      throw DatabaseException('Operación fallida en insertInstallmentPlan', e);
    }
  }

  Future<int> insertMovimiento(model.Transaction mov) async {
    return await insertTransaction(mov);
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'transactions',
        where: 'is_secret = 0',
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getAllTransactions): $e');
      throw DatabaseException('Operación fallida en getAllTransactions', e);
    }
  }

  Future<int> insertGoal(Goal goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final map = goal.toMap();
      // Map naming convention if needed, though SavingsGoal.toMap() should be consistent
      return await db.insert('goals', {
        'id': map['id'],
        'name': map['name'],
        'target_amount': Money.round((map['targetAmount'] as num).toDouble()),
        'saved_amount': Money.round((map['currentAmount'] as num).toDouble()),
        'target_date': map['targetDate'],
        'icon': map['icon'],
        'created_at': map['createdAt'],
      });
    } catch (e, _) {
      debugPrint('DB Error (insertGoal): $e');
      throw DatabaseException('Operación fallida en insertGoal', e);
    }
  }

  Future<List<Goal>> getGoals() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('goals');
      return result.map((json) {
        return Goal(
          id: json['id'] as int?,
          name: json['name'] as String,
          targetAmount: (json['target_amount'] as num).toDouble(),
          currentAmount: (json['saved_amount'] as num).toDouble(),
          targetDate: json['target_date'] != null
              ? DateTime.parse(json['target_date'] as String)
              : DateTime.now(),
          icon: (json['icon'] as String?) ?? '🚗',
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e, _) {
      debugPrint('DB Error (getGoals): $e');
      throw DatabaseException('Operación fallida en getGoals', e);
    }
  }

  Future<int> updateGoal(Goal goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final map = goal.toMap();
      return await db.update(
        'goals',
        {
          'name': map['name'],
          'target_amount': Money.round((map['targetAmount'] as num).toDouble()),
          'saved_amount': Money.round((map['currentAmount'] as num).toDouble()),
          'target_date': map['targetDate'],
          'icon': map['icon'],
          'created_at': map['createdAt'],
        },
        where: 'id = ?',
        whereArgs: [goal.id],
      );
    } catch (e, _) {
      debugPrint('DB Error (updateGoal): $e');
      throw DatabaseException('Operación fallida en updateGoal', e);
    }
  }

  Future<int> deleteGoal(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    } catch (e, _) {
      debugPrint('DB Error (deleteGoal): $e');
      throw DatabaseException('Operación fallida en deleteGoal', e);
    }
  }

  Future<void> addToGoal(int goalId, double amount) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute(
        'UPDATE goals SET saved_amount = ROUND(saved_amount + ?, 2) WHERE id = ?',
        [Money.round(amount), goalId],
      );
    } catch (e, _) {
      debugPrint('DB Error (addToGoal): $e');
      throw DatabaseException('Operación fallida en addToGoal', e);
    }
  }

  Future<List<model.Transaction>> getTransactionsToday({
    bool isSecret = false,
  }) async {
    return getTransactionsForDay(DateTime.now(), isSecret: isSecret);
  }

  Future<List<model.Transaction>> getTransactionsForDay(
    DateTime day, {
    bool isSecret = false,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final startOfDay = DateTime(
        day.year,
        day.month,
        day.day,
      ).toIso8601String();
      final endOfDay = DateTime(
        day.year,
        day.month,
        day.day,
        23,
        59,
        59,
        999,
      ).toIso8601String();

      final result = await db.query(
        'transactions',
        where: 'date >= ? AND date <= ? AND is_secret = ?',
        whereArgs: [startOfDay, endOfDay, isSecret ? 1 : 0],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getTransactionsForDay): $e');
      throw DatabaseException('Operación fallida en getTransactionsForDay', e);
    }
  }

  Future<List<model.Transaction>> getTransactionsThisWeek() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      ).toIso8601String();

      final result = await db.query(
        'transactions',
        where: 'date >= ? AND is_secret = 0',
        whereArgs: [startDate],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getTransactionsThisWeek): $e');
      throw DatabaseException(
        'Operación fallida en getTransactionsThisWeek',
        e,
      );
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e, _) {
      debugPrint('DB Error (deleteTransaction): $e');
      throw DatabaseException('Operación fallida en deleteTransaction', e);
    }
  }

  Future<int> updateTransaction(model.Transaction mov) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.update(
        'transactions',
        mov.toMap(),
        where: 'id = ?',
        whereArgs: [mov.id],
      );
    } catch (e, _) {
      debugPrint('DB Error (updateTransaction): $e');
      throw DatabaseException('Operación fallida en updateTransaction', e);
    }
  }

  Future<List<model.Transaction>> getSecretTransactions() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'transactions',
        where: 'is_secret = 1',
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getSecretTransactions): $e');
      throw DatabaseException('Operación fallida en getSecretTransactions', e);
    }
  }

  Future<void> moveToVault(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'transactions',
        {'is_secret': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, _) {
      debugPrint('DB Error (moveToVault): $e');
      throw DatabaseException('Operación fallida en moveToVault', e);
    }
  }

  Future<void> moveToNormal(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'transactions',
        {'is_secret': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, _) {
      debugPrint('DB Error (moveToNormal): $e');
      throw DatabaseException('Operación fallida en moveToNormal', e);
    }
  }

  Future<List<model.Transaction>> getTransactionsByType(String type) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final normalizedType = model.Transaction.normalizeType(type);
      final legacyType = normalizedType == model.Transaction.typeIncome
          ? 'income'
          : 'expense';
      final result = await db.query(
        'transactions',
        where: 'type IN (?, ?) AND is_secret = 0',
        whereArgs: [normalizedType, legacyType],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getTransactionsByType): $e');
      throw DatabaseException('Operación fallida en getTransactionsByType', e);
    }
  }

  Future<List<model.Transaction>> getTransactionsInMonth({
    DateTime? month,
    bool isSecret = false,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final date = month ?? DateTime.now();
      final startOfMonth = DateTime(date.year, date.month).toIso8601String();
      final startOfNextMonth = DateTime(
        date.year,
        date.month + 1,
      ).toIso8601String();

      final result = await db.query(
        'transactions',
        where: 'date >= ? AND date < ? AND is_secret = ?',
        whereArgs: [startOfMonth, startOfNextMonth, isSecret ? 1 : 0],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getTransactionsInMonth): $e');
      throw DatabaseException('Operación fallida en getTransactionsInMonth', e);
    }
  }

  Future<void> processRecurringTransactions() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();

      await db.transaction((txn) async {
        final pending = await txn.query(
          'recurring_transactions',
          where: 'next_date <= ?',
          whereArgs: [now.toIso8601String()],
        );

        for (var row in pending) {
          final schedule = RecurrenceSchedule.dueOccurrences(
            nextDate: DateTime.parse(row['next_date'] as String),
            frequency: row['frequency'] as String,
            now: now,
            anchorDay: row['anchor_day'] as int?,
          );

          // Se generan TODAS las ocurrencias atrasadas, no solo una por
          // apertura de la app. En un plan de cuotas, solo las que faltan.
          final due = InstallmentPlan.cap(schedule.due, row);
          final total = row['installments_total'] as int?;
          final paid = (row['installments_paid'] as int?) ?? 0;

          for (var i = 0; i < due.length; i++) {
            await txn.insert('transactions', {
              'amount': total == null
                  ? row['amount']
                  : InstallmentPlan.amountFor(
                      k: paid + i + 1,
                      count: total,
                      perInstallment: (row['amount'] as num).toDouble(),
                      totalAmount: (row['installments_total_amount'] as num?)
                          ?.toDouble(),
                    ),
              'category': row['category'],
              'type': row['type'],
              'note': total == null
                  ? row['note']
                  : InstallmentPlan.noteFor(
                      row['note'] as String?,
                      paid + i + 1,
                      total,
                    ),
              'date': due[i].toIso8601String(),
              'is_secret': (row['is_secret'] as int?) ?? 0,
              'is_recurring': 1,
            });
          }

          if (total != null && paid + due.length >= total) {
            // Plan terminado: la última cuota ya se registró.
            await txn.delete(
              'recurring_transactions',
              where: 'id = ?',
              whereArgs: [row['id']],
            );
            continue;
          }

          final nextDate = due.length == schedule.due.length
              ? schedule.upcoming
              : schedule.due[due.length];
          await txn.update(
            'recurring_transactions',
            {
              'next_date': nextDate.toIso8601String(),
              if (total != null) 'installments_paid': paid + due.length,
            },
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      });
    } catch (e, _) {
      debugPrint('DB Error (processRecurringTransactions): $e');
      throw DatabaseException(
        'Operación fallida en processRecurringTransactions',
        e,
      );
    }
  }

  /// Restaura un backup completo en UNA transacción: si algo falla no queda
  /// una restauración a medias. Recibe filas con nombres de columna de la DB.
  /// Devuelve cuántas filas se restauraron por tabla.
  Future<Map<String, int>> restoreBackupData(
    Map<String, List<Map<String, Object?>>> rowsByTable,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final counts = <String, int>{};
      await db.transaction((txn) async {
        for (final entry in rowsByTable.entries) {
          final table = entry.key;
          final keys = BackupMerge.keyFields[table];
          if (keys == null) continue;
          // Filas que ya estaban en el teléfono antes de restaurar. Cada una
          // puede "absorber" una sola fila del archivo: si el backup trae
          // dos movimientos iguales y el teléfono uno, se agrega el otro.
          final unclaimed = List.of(await txn.query(table));
          var count = 0;
          for (final incoming in entry.value) {
            Map<String, Object?>? existing;
            if (incoming['id'] != null) {
              final found = await txn.query(
                table,
                where: 'id = ?',
                whereArgs: [incoming['id']],
              );
              existing = found.isEmpty ? null : found.first;
            }
            var action = BackupMerge.decide(
              existing,
              incoming,
              keys,
              table: table,
            );
            if (action == MergeAction.replace || action == MergeAction.skip) {
              unclaimed.removeWhere((r) => r['id'] == existing!['id']);
            } else {
              // La misma entidad ya está con otro id (por ejemplo, una
              // restauración anterior la insertó como nueva): no se duplica.
              final twin = unclaimed.indexWhere(
                (r) => BackupMerge.sameEntity(r, incoming, keys),
              );
              if (twin >= 0) {
                unclaimed.removeAt(twin);
                action = MergeAction.skip;
              }
            }
            switch (action) {
              case MergeAction.skip:
                continue;
              case MergeAction.insertWithId:
                await txn.insert(table, incoming);
              case MergeAction.replace:
                await txn.insert(
                  table,
                  incoming,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              case MergeAction.insertAsNew:
                await txn.insert(table, Map.of(incoming)..remove('id'));
            }
            count++;
          }
          counts[table] = count;
        }
      });
      return counts;
    } catch (e, _) {
      debugPrint('DB Error (restoreBackupData): $e');
      throw DatabaseException('Operación fallida en restoreBackupData', e);
    }
  }

  /// Recurrencias activas (para la futura pantalla de suscripciones).
  Future<List<Map<String, Object?>>> getRecurringTransactions({
    bool isSecret = false,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.query(
        'recurring_transactions',
        where: 'is_secret = ?',
        whereArgs: [isSecret ? 1 : 0],
        orderBy: 'next_date ASC',
      );
    } catch (e, _) {
      debugPrint('DB Error (getRecurringTransactions): $e');
      throw DatabaseException(
        'Operación fallida en getRecurringTransactions',
        e,
      );
    }
  }

  /// Actualiza el monto de una recurrencia (aumentos de precio). Solo afecta
  /// a las próximas ocurrencias.
  ///
  /// En un plan de cuotas el total se recalcula como cuota × total de cuotas:
  /// si quedara el total viejo, la última cuota (que absorbe el redondeo)
  /// saldría con cualquier monto, incluso negativo.
  Future<int> updateRecurringAmount(int id, double amount) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'recurring_transactions',
        columns: ['installments_total'],
        where: 'id = ?',
        whereArgs: [id],
      );
      final total = rows.isEmpty
          ? null
          : rows.first['installments_total'] as int?;
      return await db.update(
        'recurring_transactions',
        {
          'amount': Money.round(amount),
          if (total != null)
            'installments_total_amount': Money.fromCents(
              Money.toCents(amount) * total,
            ),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, _) {
      debugPrint('DB Error (updateRecurringAmount): $e');
      throw DatabaseException('Operación fallida en updateRecurringAmount', e);
    }
  }

  /// Cancela una recurrencia. Los movimientos ya generados se conservan.
  Future<int> deleteRecurringTransaction(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete(
        'recurring_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, _) {
      debugPrint('DB Error (deleteRecurringTransaction): $e');
      throw DatabaseException(
        'Operación fallida en deleteRecurringTransaction',
        e,
      );
    }
  }

  Future<List<model.Transaction>> searchTransactions(String query) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final search = '%$query%';
      final result = await db.query(
        'transactions',
        where:
            'is_secret = 0 AND (category LIKE ? OR note LIKE ? OR amount LIKE ? OR date LIKE ?)',
        whereArgs: [search, search, search, search],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (searchTransactions): $e');
      throw DatabaseException('Operación fallida en searchTransactions', e);
    }
  }

  Future<List<model.Transaction>> searchTransactionsByType(
    String query,
    String type,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final search = '%$query%';
      final normalizedType = model.Transaction.normalizeType(type);
      final legacyType = normalizedType == model.Transaction.typeIncome
          ? 'income'
          : 'expense';
      final result = await db.query(
        'transactions',
        where:
            'type IN (?, ?) AND is_secret = 0 AND (category LIKE ? OR note LIKE ? OR amount LIKE ? OR date LIKE ?)',
        whereArgs: [normalizedType, legacyType, search, search, search, search],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (searchTransactionsByType): $e');
      throw DatabaseException(
        'Operación fallida en searchTransactionsByType',
        e,
      );
    }
  }

  // Legacy mappings for TransactionRepository
  Future<List<model.Transaction>> getNormalMovimientos() =>
      getAllTransactions();
  Future<List<model.Transaction>> getVaultMovimientos() =>
      getSecretTransactions();
  Future<List<model.Transaction>> getIncomeMovimientos() =>
      getTransactionsByType('ingreso');
  Future<List<model.Transaction>> getExpenseMovimientos() =>
      getTransactionsByType('gasto');
  Future<List<model.Transaction>> searchMovimientos(String query) =>
      searchTransactions(query);
  Future<List<model.Transaction>> searchMovimientosByType(
    String query,
    String type,
  ) => searchTransactionsByType(query, type);
  Future<int> updateMovimiento(model.Transaction mov) => updateTransaction(mov);

  Future<List<String>> getCategoriasOrdenadas(String type) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final normalizedType = model.Transaction.normalizeType(type);
      final legacyType = normalizedType == model.Transaction.typeIncome
          ? 'income'
          : 'expense';
      final result = await db.rawQuery(
        // Sin is_secret = 0 la Bóveda influía en el orden de categorías.
        'SELECT category, COUNT(*) as count FROM transactions WHERE type IN (?, ?) AND is_secret = 0 GROUP BY category ORDER BY count DESC',
        [normalizedType, legacyType],
      );
      return result.map((row) => row['category'] as String).toList();
    } catch (e, _) {
      debugPrint('DB Error (getCategoriasOrdenadas): $e');
      throw DatabaseException('Operación fallida en getCategoriasOrdenadas', e);
    }
  }

  // Debt Methods
  Future<int> insertDebt(Debt debt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('debts', debt.toMap());
    } catch (e, _) {
      debugPrint('DB Error (insertDebt): $e');
      throw DatabaseException('Operación fallida en insertDebt', e);
    }
  }

  Future<List<Debt>> getDebts() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('debts');
      return result.map((json) => Debt.fromMap(json)).toList();
    } catch (e, _) {
      debugPrint('DB Error (getDebts): $e');
      throw DatabaseException('Operación fallida en getDebts', e);
    }
  }

  Future<int> updateDebt(Debt debt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.update(
        'debts',
        debt.toMap(),
        where: 'id = ?',
        whereArgs: [debt.id],
      );
    } catch (e, _) {
      debugPrint('DB Error (updateDebt): $e');
      throw DatabaseException('Operación fallida en updateDebt', e);
    }
  }

  Future<int> deleteDebt(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    } catch (e, _) {
      debugPrint('DB Error (deleteDebt): $e');
      throw DatabaseException('Operación fallida en deleteDebt', e);
    }
  }

  Future<void> payDebt(int debtId, double amount) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute(
        'UPDATE debts SET monto_pagado = ROUND(monto_pagado + ?, 2) WHERE id = ?',
        [Money.round(amount), debtId],
      );
    } catch (e, _) {
      debugPrint('DB Error (payDebt): $e');
      throw DatabaseException('Operación fallida en payDebt', e);
    }
  }

  Future close() async {
    try {
      final db = await DatabaseHelper.instance.database;
      _database = null;
      await db.close();
    } catch (e) {
      debugPrint('DB Error (close): $e');
    }
  }
}
