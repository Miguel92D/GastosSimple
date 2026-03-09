import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService extends ChangeNotifier {
  static final SecurityService instance = SecurityService._init();
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  bool _isPinActive = false;
  bool _isBiometricActive = false;
  bool _isUnlocked = false;
  String? _pin;

  SecurityService._init() {
    _loadSecuritySettings();
  }

  bool get isPinActive => _isPinActive;
  bool get isBiometricActive => _isBiometricActive;
  bool get isUnlocked => _isUnlocked;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;

  void lock() {
    _isUnlocked = false;
    notifyListeners();
  }

  void unlock() {
    _isUnlocked = true;
    notifyListeners();
  }

  Future<void> _loadSecuritySettings() async {
    _isPinActive = (await _storage.read(key: 'is_pin_active')) == 'true';
    _isBiometricActive =
        (await _storage.read(key: 'is_biometric_active')) == 'true';
    _pin = await _storage.read(key: 'pin');
    notifyListeners();
  }

  Future<void> setPinActive(bool value) async {
    await _storage.write(key: 'is_pin_active', value: value.toString());
    _isPinActive = value;
    notifyListeners();
  }

  Future<void> setBiometricActive(bool value) async {
    await _storage.write(key: 'is_biometric_active', value: value.toString());
    _isBiometricActive = value;
    notifyListeners();
  }

  Future<void> setPin(String value) async {
    await _storage.write(key: 'pin', value: value);
    _pin = value;
    notifyListeners();
  }

  Future<bool> authenticatePin(String input) async {
    return _pin == input;
  }

  Future<bool> authenticateBiometric() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || isDeviceSupported;

      debugPrint(
        "Security: Biometric available: $canAuthenticateWithBiometrics, Supported: $isDeviceSupported",
      );

      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: 'Autentícate para acceder a tus finanzas',
        // Note: 'options' and 'AuthenticationOptions' are not supported
        // by the current local_auth version in this environment.
      );
    } catch (e) {
      debugPrint("Security: Error in biometric auth: $e");
      return false;
    }
  }

  static Future<bool> checkSecurity(BuildContext context) async {
    final service = SecurityService.instance;
    final isEnabled = service.isPinActive || service.isBiometricActive;
    debugPrint("Security: Security enabled: $isEnabled");
    return isEnabled;
  }
}
