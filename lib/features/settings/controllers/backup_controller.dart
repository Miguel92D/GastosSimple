import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../../goals/models/goal.dart';
import '../../debts/models/debt.dart';
import '../../../database/database_helper.dart';
import '../../../core/notifiers/transaction_notifier.dart';
import '../../../core/utils/money.dart';

class BackupController {
  /// Formato v3: v2 + recurrencias + flag de si incluye la Bóveda.
  /// El restore sigue aceptando v1 (lista plana) y v2.
  static const int backupVersion = 3;

  static Future<bool> hasVaultData() async {
    final vault = await TransactionRepository.getVaultTransactions();
    if (vault.isNotEmpty) return true;
    final recurring = await DatabaseHelper.instance.getRecurringTransactions(
      isSecret: true,
    );
    return recurring.isNotEmpty;
  }

  /// [includeVault]: el archivo es un JSON sin cifrar que sale del teléfono
  /// por el menú de compartir; la Bóveda solo se incluye si el usuario lo
  /// pide explícitamente.
  static Future<String> exportBackup({bool includeVault = false}) async {
    try {
      final normal = await TransactionRepository.getNormalTransactions();
      final vault = includeVault
          ? await TransactionRepository.getVaultTransactions()
          : <Transaction>[];
      final goals = await DatabaseHelper.instance.getGoals();
      final debts = await DatabaseHelper.instance.getDebts();
      final recurring = [
        ...await DatabaseHelper.instance.getRecurringTransactions(),
        if (includeVault)
          ...await DatabaseHelper.instance.getRecurringTransactions(
            isSecret: true,
          ),
      ];

      final Map<String, dynamic> jsonData = {
        'version': backupVersion,
        'created_at': DateTime.now().toIso8601String(),
        'includes_vault': includeVault,
        'transactions': [
          ...normal.map((e) => e.toMap()),
          ...vault.map((e) => e.toMap()),
        ],
        'goals': goals.map((e) => e.toMap()).toList(),
        'debts': debts.map((e) => e.toMap()).toList(),
        'recurring_transactions': recurring,
      };

      final String jsonString = jsonEncode(jsonData);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/gastos_simple_backup.json');
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      debugPrint('Backup export error: $e');
      rethrow;
    }
  }

  /// Restaura sin pisar datos existentes y de forma atómica
  /// (ver [DatabaseHelper.restoreBackupData]).
  static Future<Map<String, int>> restoreBackup(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final dynamic parsed = jsonDecode(content);

      final List<dynamic> txItems;
      List<dynamic> goalItems = const [];
      List<dynamic> debtItems = const [];
      List<dynamic> recurringItems = const [];

      if (parsed is List) {
        txItems = parsed; // v1
      } else if (parsed is Map<String, dynamic>) {
        txItems = parsed['transactions'] as List? ?? const [];
        goalItems = parsed['goals'] as List? ?? const [];
        debtItems = parsed['debts'] as List? ?? const [];
        recurringItems = parsed['recurring_transactions'] as List? ?? const [];
      } else {
        throw const FormatException('Formato de backup no reconocido');
      }

      // Se parsea TODO antes de tocar la base: un archivo corrupto falla
      // acá, sin escribir nada.
      final rows = <String, List<Map<String, Object?>>>{
        'transactions': [
          for (final item in txItems)
            Transaction.fromMap(Map<String, dynamic>.from(item as Map)).toMap(),
        ],
        'goals': [
          for (final item in goalItems)
            _goalToRow(Goal.fromMap(Map<String, dynamic>.from(item as Map))),
        ],
        'debts': [
          for (final item in debtItems)
            Debt.fromMap(Map<String, dynamic>.from(item as Map)).toMap(),
        ],
        'recurring_transactions': [
          for (final item in recurringItems) _recurringRow(item as Map),
        ],
      };

      final counts = await DatabaseHelper.instance.restoreBackupData(rows);
      TransactionNotifier.instance.refresh();
      return counts;
    } catch (e) {
      debugPrint('Backup restore error: $e');
      rethrow;
    }
  }

  static Map<String, Object?> _goalToRow(Goal goal) {
    final map = goal.toMap();
    return {
      'id': map['id'],
      'name': map['name'],
      'target_amount': Money.round((map['targetAmount'] as num).toDouble()),
      'saved_amount': Money.round((map['currentAmount'] as num).toDouble()),
      'target_date': map['targetDate'],
      'icon': map['icon'],
      'created_at': map['createdAt'],
    };
  }

  static Map<String, Object?> _recurringRow(Map item) {
    final next = item['next_date'] as String;
    DateTime.parse(next); // valida el formato antes de escribir
    return {
      'id': item['id'],
      'amount': Money.round((item['amount'] as num).toDouble()),
      'category': item['category'] as String,
      'type': item['type'] as String,
      'note': item['note'],
      'frequency': item['frequency'] as String,
      'next_date': next,
      'is_secret': (item['is_secret'] as int?) ?? 0,
      'anchor_day': item['anchor_day'] as int?,
      'installments_total': item['installments_total'] as int?,
      'installments_paid': item['installments_paid'] as int?,
      'installments_total_amount':
          (item['installments_total_amount'] as num?)?.toDouble(),
    };
  }
}
