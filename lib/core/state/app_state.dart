import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  static const String _proEntitlementKey = 'is_pro';

  AppState._();

  bool _isPro = false;
  bool vaultOpen = false;
  bool hideBalance = false;
  bool _refreshDashboard = false;

  bool get isPro => _isPro;
  bool get refreshDashboard => _refreshDashboard;

  Future<void> loadProEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_proEntitlementKey) ?? false;
    notifyListeners();
  }

  Future<void> setProEntitlement(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proEntitlementKey, value);
    setPro(value);
  }

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
