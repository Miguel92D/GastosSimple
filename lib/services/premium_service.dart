import 'package:flutter/material.dart';
import '../core/flow/premium_flow_service.dart';
import '../core/state/app_state.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService instance = PremiumService._init();

  PremiumService._init();

  bool get isPremium => AppState.instance.isPro;
  static bool get isPro => instance.isPremium;

  static Future<bool> checkPremium(BuildContext context) async {
    if (AppState.instance.isPro) return true;
    PremiumFlowService.showUpgradePrompt(context);
    return false;
  }
}
