import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/transactions/models/transaction.dart';
import '../features/transactions/repositories/transaction_repository.dart';
import '../core/notifiers/transaction_notifier.dart';
import 'pro_service.dart';

class CloudBackupService {
  static final instance = CloudBackupService._init();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  CloudBackupService._init();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelled by user

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error during Google Sign In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> backupData() async {
    if (!ProService.instance.isPro) return;

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    // Get all transactions (normal + vault)
    final normal = await TransactionRepository.getNormalTransactions();
    final vault = await TransactionRepository.getVaultTransactions();
    final transactions = [...normal, ...vault];

    final batch = _firestore.batch();

    for (var transaction in transactions) {
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(transaction.id.toString());

      batch.set(ref, transaction.toMap());
    }

    try {
      await batch.commit();
      debugPrint('Backup successful.');
    } catch (e) {
      debugPrint('Backup failed: $e');
    }
  }

  Future<void> restoreData() async {
    if (!ProService.instance.isPro) return;

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final transaction = Transaction.fromMap(data);

        // Simple restore: upsert
        await TransactionRepository.updateTransaction(transaction);
        // Note: In a real app we'd check if update actually did something
        // or just use an upsert method in repository.
      }
      TransactionNotifier.instance.refresh();
      debugPrint('Restore successful.');
    } catch (e) {
      debugPrint('Restore failed: $e');
    }
  }

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_backup_enabled') ?? false;
  }

  Future<void> setAutoBackupEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup_enabled', value);
  }

  Future<void> tryAutoBackup() async {
    if (!ProService.instance.isPro) return;
    final isEnabled = await isAutoBackupEnabled();
    if (isEnabled && _auth.currentUser != null) {
      await backupData();
    }
  }
}
