import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._();

  bool _isPro = false;
  bool vaultOpen = false;
  bool hideBalance = false;
  bool _refreshDashboard = false;

  bool get isPro => _isPro;
  bool get refreshDashboard => _refreshDashboard;

  void toggleHideBalance() {
    hideBalance = !hideBalance;
    notifyListeners();
  }

  void setPro(bool value) {
    _isPro = value;
    notifyListeners();
  }

  void openVault() {
    vaultOpen = true;
    notifyListeners();
  }

  void closeVault() {
    vaultOpen = false;
    notifyListeners();
  }

  void triggerDashboardRefresh() {
    _refreshDashboard = !_refreshDashboard;
    notifyListeners();
  }
}
