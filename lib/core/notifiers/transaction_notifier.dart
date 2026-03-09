import 'package:flutter/material.dart';

class TransactionNotifier extends ChangeNotifier {
  static final TransactionNotifier instance = TransactionNotifier();

  void refresh() {
    notifyListeners();
  }
}
