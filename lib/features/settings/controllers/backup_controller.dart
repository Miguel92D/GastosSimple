import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../../../core/notifiers/transaction_notifier.dart';

class BackupController {
  static Future<String> exportBackup() async {
    try {
      final allTransactions =
          await TransactionRepository.getNormalTransactions();
      final vaultTransactions =
          await TransactionRepository.getVaultTransactions();

      final List<Map<String, dynamic>> jsonData = [
        ...allTransactions.map((e) => e.toMap()),
        ...vaultTransactions.map((e) => e.toMap()),
      ];

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
      List<dynamic> parsed = jsonDecode(content);

      for (var item in parsed) {
        final map = item as Map<String, dynamic>;
        final transaction = Transaction.fromMap(map);
        await TransactionRepository.insertTransaction(transaction);
      }

      TransactionNotifier.instance.refresh();
    } catch (e) {
      debugPrint('Backup restore error: $e');
      rethrow;
    }
  }
}
