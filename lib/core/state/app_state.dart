import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._();

  bool isPro = true;
  bool vaultOpen = false;
  bool hideBalance = false;
  bool _refreshDashboard = false;

  bool get refreshDashboard => _refreshDashboard;

  void toggleHideBalance() {
    hideBalance = !hideBalance;
    notifyListeners();
  }

  void setPro(bool value) {
    isPro = value;
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
