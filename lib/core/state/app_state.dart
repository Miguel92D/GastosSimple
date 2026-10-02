import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  bool _hasConsented = false;

  static const String _consentKey = 'has_consented';
  static const String _crashReportsKey = 'crash_reports_enabled';

  /// true cuando el usuario ya vio y respondió la pantalla de consentimiento.
  bool get hasConsented => _hasConsented;

  Future<void> loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    _hasConsented = prefs.getBool(_consentKey) ?? false;
    final crash = prefs.getBool(_crashReportsKey) ?? false;
    await _setCrashlytics(_hasConsented && crash);
  }

  Future<void> setConsent({required bool crashReports}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    await prefs.setBool(_crashReportsKey, crashReports);
    await _setCrashlytics(crashReports);
    _hasConsented = true;
    notifyListeners();
  }

  Future<void> _setCrashlytics(bool enabled) async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        enabled,
      );
    } catch (e) {
      debugPrint('Crashlytics toggle error: $e');
    }
  }

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
