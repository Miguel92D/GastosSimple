import 'package:flutter/material.dart';
import 'app_mode.dart';

class AppModeController extends ChangeNotifier {
  static final AppModeController instance = AppModeController._();

  AppModeController._();

  AppMode _mode = AppMode.normal;

  AppMode get mode => _mode;

  bool get isPro => _mode == AppMode.pro;

  bool get isVault => _mode == AppMode.vault;

  void setNormal() {
    _mode = AppMode.normal;
    notifyListeners();
  }

  void setPro() {
    _mode = AppMode.pro;
    notifyListeners();
  }

  void setVault() {
    _mode = AppMode.vault;
    notifyListeners();
  }

  void setVaultMode(bool isVault) {
    _mode = isVault ? AppMode.vault : AppMode.normal;
    notifyListeners();
  }
}
