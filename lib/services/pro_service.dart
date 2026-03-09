import 'package:flutter/foundation.dart';

class ProService extends ChangeNotifier {
  static final ProService instance = ProService._internal();

  ProService._internal();

  bool _isPro = true; // temporary true for testing
  final bool _isVaultActive = false;

  bool get isPro => _isPro;
  bool get isVaultActive => _isVaultActive;

  void activatePro() {
    _isPro = true;
    notifyListeners();
  }

  void deactivatePro() {
    _isPro = false;
    notifyListeners();
  }
}
