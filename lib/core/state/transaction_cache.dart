import '../../features/transactions/models/transaction.dart';

class TransactionCache {
  static List<Transaction> cache = [];

  static void set(List<Transaction> data) {
    cache = data;
  }

  static List<Transaction> get() {
    return cache;
  }

  static void clear() {
    cache = [];
  }
}
