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

class BackupController {
  /// Formato v2: objeto versionado con transacciones, metas y deudas.
  /// El restore sigue aceptando el formato v1 (lista plana de transacciones).
  static const int backupVersion = 2;

  static Future<String> exportBackup() async {
    try {
      final allTransactions =
          await TransactionRepository.getNormalTransactions();
      final vaultTransactions =
          await TransactionRepository.getVaultTransactions();
      final goals = await DatabaseHelper.instance.getGoals();
      final debts = await DatabaseHelper.instance.getDebts();

      final Map<String, dynamic> jsonData = {
        'version': backupVersion,
        'created_at': DateTime.now().toIso8601String(),
        'transactions': [
          ...allTransactions.map((e) => e.toMap()),
          ...vaultTransactions.map((e) => e.toMap()),
        ],
        'goals': goals.map((e) => e.toMap()).toList(),
        'debts': debts.map((e) => e.toMap()).toList(),
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

  static Future<void> restoreBackup(String filePath) async {
    try {
      File file = File(filePath);
      String content = await file.readAsString();
      final dynamic parsed = jsonDecode(content);

      if (parsed is List) {
        // Formato v1: lista plana de transacciones.
        await _restoreTransactions(parsed);
      } else if (parsed is Map<String, dynamic>) {
        await _restoreTransactions(parsed['transactions'] as List? ?? []);

        for (final item in parsed['goals'] as List? ?? []) {
          await DatabaseHelper.instance.restoreGoal(
            Goal.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }

        for (final item in parsed['debts'] as List? ?? []) {
          await DatabaseHelper.instance.restoreDebt(
            Debt.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      } else {
        throw const FormatException('Formato de backup no reconocido');
      }

      TransactionNotifier.instance.refresh();
    } catch (e) {
      debugPrint('Backup restore error: $e');
      rethrow;
    }
  }

  static Future<void> _restoreTransactions(List<dynamic> items) async {
    for (final item in items) {
      final map = Map<String, dynamic>.from(item as Map);
      final transaction = Transaction.fromMap(map);
      await DatabaseHelper.instance.restoreTransaction(transaction);
    }
  }
}
