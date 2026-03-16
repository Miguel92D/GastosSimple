import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class CloudBackupService {
  CloudBackupService._();
  static final CloudBackupService instance = CloudBackupService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> tryAutoBackup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('CloudBackupService: User not authenticated. Skipping backup.');
        return;
      }

      final userId = user.uid;
      final userDoc = _firestore.collection('users').doc(userId);

      // Metadatos del respaldo
      await userDoc.set({
        'lastBackup': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'appVersion': '1.1.0',
        'status': 'active',
      }, SetOptions(merge: true));

      // Sincronización básica de transacciones recientes
      final transactions = await DatabaseHelper.instance.getTransactionsToday();
      if (transactions.isNotEmpty) {
        final batch = _firestore.batch();
        for (var tx in transactions) {
          final txRef = userDoc.collection('transactions').doc(tx.id.toString());
          batch.set(txRef, tx.toMap());
        }
        await batch.commit();
      }

      debugPrint('CloudBackupService: Auto-backup successful for $userId');
    } catch (e) {
      debugPrint('CloudBackupService Error: $e');
    }
  }

  Future<void> fullBackup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final userId = user.uid;
      final userDoc = _firestore.collection('users').doc(userId);
      
      final allTx = await DatabaseHelper.instance.getAllTransactions();
      final vaultTx = await DatabaseHelper.instance.getSecretTransactions();
      
      // Procesamiento por lotes (Firestore limit: 500 writes)
      await _uploadInBatches(userDoc.collection('transactions'), allTx);
      await _uploadInBatches(userDoc.collection('vault_transactions'), vaultTx);
      
      await userDoc.update({'lastFullBackup': FieldValue.serverTimestamp()});
      debugPrint('CloudBackupService: Full backup complete');
    } catch (e) {
      debugPrint('CloudBackupService Full Backup Error: $e');
    }
  }

  Future<void> _uploadInBatches(CollectionReference ref, List<dynamic> items) async {
    for (var i = 0; i < items.length; i += 400) {
      final end = (i + 400 < items.length) ? i + 400 : items.length;
      final chunk = items.sublist(i, end);
      
      final batch = _firestore.batch();
      for (var item in chunk) {
        batch.set(ref.doc(item.id.toString()), item.toMap());
      }
      await batch.commit();
    }
  }

  Future<void> restoreBackup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        debugPrint('CloudBackupService: Backup found for ${user.uid}');
      }
    } catch (e) {
      debugPrint('CloudBackupService Restore Error: $e');
    }
  }
}
