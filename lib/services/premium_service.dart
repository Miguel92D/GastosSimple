import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/flow/premium_flow_service.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService instance = PremiumService._init();
  final _storage = const FlutterSecureStorage();
  bool _isPremium = true;

  PremiumService._init() {
    _loadPremiumState();
  }

  bool get isPremium => _isPremium;
  static bool get isPro => instance.isPremium;

  Future<void> _loadPremiumState() async {
    final value = await _storage.read(key: 'is_premium');
    _isPremium = value == 'true';
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    await _storage.write(key: 'is_premium', value: value.toString());
    _isPremium = value;
    notifyListeners();
  }

  static Future<bool> checkPremium(BuildContext context) async {
    if (instance.isPremium) return true;
    PremiumFlowService.showUpgradePrompt(context);
    return false;
  }
}
