import 'package:flutter/foundation.dart';
import '../core/state/app_state.dart';

class ProService extends ChangeNotifier {
  static final ProService instance = ProService._internal();

  ProService._internal();

  final bool _isVaultActive = false;

  bool get isPro => AppState.instance.isPro;
  bool get isVaultActive => _isVaultActive;

  void activatePro() {
    AppState.instance.setPro(true);
    notifyListeners();
  }

  void deactivatePro() {
    AppState.instance.setPro(false);
    notifyListeners();
  }
}
