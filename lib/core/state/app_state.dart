import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._();

  bool isPro = false;
  bool vaultOpen = false;
  bool _refreshDashboard = false;

  bool get refreshDashboard => _refreshDashboard;

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
