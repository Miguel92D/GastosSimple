import 'package:flutter/foundation.dart';
import '../core/state/app_state.dart';

/// Solo lectura del estado Pro. Pro lo activa únicamente PurchaseService
/// después de una compra o restauración en Google Play.
class ProService extends ChangeNotifier {
  static final ProService instance = ProService._internal();

  ProService._internal();

  final bool _isVaultActive = false;

  bool get isPro => AppState.instance.isPro;
  bool get isVaultActive => _isVaultActive;
}
