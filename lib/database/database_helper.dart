import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../features/transactions/models/transaction.dart' as model;
import '../core/error/exceptions.dart';
import '../features/goals/models/goal.dart';
import '../features/debts/models/debt.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('simple_wallet.db'); // Consistent name
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 12, // Added cuotas to debts
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
  next_date $textType
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
      try {
        await db.execute('ALTER TABLE debts ADD COLUMN cuotas_totales INTEGER');
        await db.execute('ALTER TABLE debts ADD COLUMN cuotas_pagadas INTEGER');
      } catch (_) {}
    }
  }

  Future<int> insertTransaction(model.Transaction mov) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('transactions', mov.toMap());
    } catch (e, _)  {
      debugPrint('DB Error (insertTransaction): $e');
      throw DatabaseException('Operación fallida en insertTransaction', e);
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
    } catch (e, _)  {
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
      DateTime nextDate;
      if (frequency == 'daily') {
        nextDate = mov.date.add(const Duration(days: 1));
      } else if (frequency == 'weekly') {
        nextDate = mov.date.add(const Duration(days: 7));
      } else {
        nextDate = DateTime(mov.date.year, mov.date.month + 1, mov.date.day);
      }

      return await db.insert('recurring_transactions', {
        'amount': mov.amount,
        'category': mov.category,
        'type': mov.type,
        'note': mov.note,
        'frequency': frequency,
        'next_date': nextDate.toIso8601String(),
      });
    } catch (e, _)  {
      debugPrint('DB Error (insertRecurringTransaction): $e');
      throw DatabaseException('Operación fallida en insertRecurringTransaction', e);
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
    } catch (e, _)  {
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
        'target_amount': map['targetAmount'],
        'saved_amount': map['currentAmount'],
        'target_date': map['targetDate'],
        'icon': map['icon'],
        'created_at': map['createdAt'],
      });
    } catch (e, _)  {
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
    } catch (e, _)  {
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
          'target_amount': map['targetAmount'],
          'saved_amount': map['currentAmount'],
          'target_date': map['targetDate'],
          'icon': map['icon'],
          'created_at': map['createdAt'],
        },
        where: 'id = ?',
        whereArgs: [goal.id],
      );
    } catch (e, _)  {
      debugPrint('DB Error (updateGoal): $e');
      throw DatabaseException('Operación fallida en updateGoal', e);
    }
  }

  Future<int> deleteGoal(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    } catch (e, _)  {
      debugPrint('DB Error (deleteGoal): $e');
      throw DatabaseException('Operación fallida en deleteGoal', e);
    }
  }

  Future<void> addToGoal(int goalId, double amount) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute(
        'UPDATE goals SET saved_amount = saved_amount + ? WHERE id = ?',
        [amount, goalId],
      );
    } catch (e, _)  {
      debugPrint('DB Error (addToGoal): $e');
      throw DatabaseException('Operación fallida en addToGoal', e);
    }
  }

  Future<List<model.Transaction>> getTransactionsToday({
    bool isSecret = false,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();
      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();
      final endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
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
    } catch (e, _)  {
      debugPrint('DB Error (getTransactionsToday): $e');
      throw DatabaseException('Operación fallida en getTransactionsToday', e);
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
    } catch (e, _)  {
      debugPrint('DB Error (getTransactionsThisWeek): $e');
      throw DatabaseException('Operación fallida en getTransactionsThisWeek', e);
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e, _)  {
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
    } catch (e, _)  {
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
    } catch (e, _)  {
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
    } catch (e, _)  {
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
    } catch (e, _)  {
      debugPrint('DB Error (moveToNormal): $e');
      throw DatabaseException('Operación fallida en moveToNormal', e);
    }
  }

  Future<List<model.Transaction>> getTransactionsByType(String type) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'transactions',
        where: 'type = ? AND is_secret = 0',
        whereArgs: [type],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _)  {
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
      final startOfMonth = DateTime(date.year, date.month, 1).toIso8601String();
      final endOfMonth = DateTime(
        date.year,
        date.month + 1,
        0,
        23,
        59,
        59,
      ).toIso8601String();

      final result = await db.query(
        'transactions',
        where: 'date >= ? AND date <= ? AND is_secret = ?',
        whereArgs: [startOfMonth, endOfMonth, isSecret ? 1 : 0],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _)  {
      debugPrint('DB Error (getTransactionsInMonth): $e');
      throw DatabaseException('Operación fallida en getTransactionsInMonth', e);
    }
  }

  Future<void> processRecurringTransactions() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final nowStr = DateTime.now().toIso8601String();

      await db.transaction((txn) async {
        final pending = await txn.query(
          'recurring_transactions',
          where: 'next_date <= ?',
          whereArgs: [nowStr],
        );

        for (var row in pending) {
          final fechaStr = row['next_date'] as String;
          final fecha = DateTime.parse(fechaStr);
          final frequency = row['frequency'] as String;

          await txn.insert('transactions', {
            'amount': row['amount'],
            'category': row['category'],
            'type': row['type'],
            'note': row['note'],
            'date': fechaStr,
            'is_secret': 0,
            'is_recurring': 1,
          });

          DateTime nextDate;
          if (frequency == 'daily') {
            nextDate = fecha.add(const Duration(days: 1));
          } else if (frequency == 'weekly') {
            nextDate = fecha.add(const Duration(days: 7));
          } else {
            nextDate = DateTime(fecha.year, fecha.month + 1, fecha.day);
          }

          await txn.update(
            'recurring_transactions',
            {'next_date': nextDate.toIso8601String()},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      });
    } catch (e, _)  {
      debugPrint('DB Error (processRecurringTransactions): $e');
      throw DatabaseException('Operación fallida en processRecurringTransactions', e);
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
    } catch (e, _)  {
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
      final result = await db.query(
        'transactions',
        where:
            'type = ? AND is_secret = 0 AND (category LIKE ? OR note LIKE ? OR amount LIKE ? OR date LIKE ?)',
        whereArgs: [type, search, search, search, search],
        orderBy: 'date DESC',
      );
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e, _)  {
      debugPrint('DB Error (searchTransactionsByType): $e');
      throw DatabaseException('Operación fallida en searchTransactionsByType', e);
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
      final result = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM transactions WHERE type = ? GROUP BY category ORDER BY count DESC',
        [type],
      );
      return result.map((row) => row['category'] as String).toList();
    } catch (e, _)  {
      debugPrint('DB Error (getCategoriasOrdenadas): $e');
      throw DatabaseException('Operación fallida en getCategoriasOrdenadas', e);
    }
  }

  // Debt Methods
  Future<int> insertDebt(Debt debt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('debts', debt.toMap());
    } catch (e, _)  {
      debugPrint('DB Error (insertDebt): $e');
      throw DatabaseException('Operación fallida en insertDebt', e);
    }
  }

  Future<List<Debt>> getDebts() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('debts');
      return result.map((json) => Debt.fromMap(json)).toList();
    } catch (e, _)  {
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
    } catch (e, _)  {
      debugPrint('DB Error (updateDebt): $e');
      throw DatabaseException('Operación fallida en updateDebt', e);
    }
  }

  Future<int> deleteDebt(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    } catch (e, _)  {
      debugPrint('DB Error (deleteDebt): $e');
      throw DatabaseException('Operación fallida en deleteDebt', e);
    }
  }

  Future<void> payDebt(int debtId, double amount) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute(
        'UPDATE debts SET monto_pagado = monto_pagado + ? WHERE id = ?',
        [amount, debtId],
      );
    } catch (e, _)  {
      debugPrint('DB Error (payDebt): $e');
      throw DatabaseException('Operación fallida en payDebt', e);
    }
  }

  Future<double> getTotalIncome({bool isVault = false}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        '''
        SELECT SUM(amount) as total
        FROM transactions
        WHERE type = 'ingreso'
        AND is_secret = ?
      ''',
        [isVault ? 1 : 0],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0;
    } catch (e, _)  {
      debugPrint('DB Error (getTotalIncome): $e');
      throw DatabaseException('Operación fallida en getTotalIncome', e);
    }
  }

  Future<double> getTotalExpenses({bool isVault = false}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        '''
        SELECT SUM(amount) as total
        FROM transactions
        WHERE type = 'gasto'
        AND is_secret = ?
      ''',
        [isVault ? 1 : 0],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0;
    } catch (e, _)  {
      debugPrint('DB Error (getTotalExpenses): $e');
      throw DatabaseException('Operación fallida en getTotalExpenses', e);
    }
  }

  Future<Map<String, double>> getExpensesByCategory({
    bool isVault = false,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        '''
        SELECT category, SUM(amount) as total
        FROM transactions
        WHERE type = 'gasto'
        AND is_secret = ?
        GROUP BY category
      ''',
        [isVault ? 1 : 0],
      );

      Map<String, double> data = {};
      for (var row in result) {
        final category = row['category'] as String;
        final total = (row['total'] as num?)?.toDouble() ?? 0;
        data[category] = total;
      }
      return data;
    } catch (e, _)  {
      debugPrint('DB Error (getExpensesByCategory): $e');
      throw DatabaseException('Operación fallida en getExpensesByCategory', e);
    }
  }

  Future close() async {
    try {
      final db = await DatabaseHelper.instance.database;
      db.close();
    } catch (e) {
      debugPrint('DB Error (close): $e');
    }
  }
}