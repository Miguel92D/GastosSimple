import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService extends ChangeNotifier {
  static final SecurityService instance = SecurityService._init();
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  bool _isPinActive = false;
  bool _isBiometricActive = false;
  bool _isVaultOnly = false;
  bool _isVaultPinActive = false;
  bool _isUnlocked = false;
  bool _isVaultUnlocked = false;
  String? _pin;
  String? _vaultPin;

  SecurityService._init() {
    _loadSecuritySettings();
  }

  bool get isPinActive => _isPinActive;
  bool get isBiometricActive => _isBiometricActive;
  bool get isVaultOnly => _isVaultOnly;
  bool get isVaultPinActive => _isVaultPinActive;
  bool get isUnlocked => _isUnlocked;
  bool get isVaultUnlocked => _isVaultUnlocked;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;
  bool get hasVaultPin => _vaultPin != null && _vaultPin!.isNotEmpty;

  Future<bool> get canUseBiometrics async {
    final bool canCheck = await _auth.canCheckBiometrics;
    final bool isSupported = await _auth.isDeviceSupported();
    return canCheck && isSupported;
  }


  void lock() {
    _isUnlocked = false;
    _isVaultUnlocked = false;
    notifyListeners();
  }

  void unlock() {
    _isUnlocked = true;
    notifyListeners();
  }

  void unlockVault() {
    _isVaultUnlocked = true;
    notifyListeners();
  }

  void lockVault() {
    _isVaultUnlocked = false;
    notifyListeners();
  }

  Future<void> _loadSecuritySettings() async {
    _isPinActive = (await _storage.read(key: 'is_pin_active')) == 'true';
    _isBiometricActive =
        (await _storage.read(key: 'is_biometric_active')) == 'true';
    _isVaultOnly = (await _storage.read(key: 'is_vault_only')) == 'true';
    _isVaultPinActive = (await _storage.read(key: 'is_vault_pin_active')) == 'true';
    _pin = await _storage.read(key: 'pin');
    _vaultPin = await _storage.read(key: 'vault_pin');
    notifyListeners();
  }

  Future<void> setPinActive(bool value) async {
    await _storage.write(key: 'is_pin_active', value: value.toString());
    _isPinActive = value;
    notifyListeners();
  }

  Future<void> setVaultPinActive(bool value) async {
    await _storage.write(key: 'is_vault_pin_active', value: value.toString());
    _isVaultPinActive = value;
    notifyListeners();
  }

  Future<void> setVaultOnly(bool value) async {
    await _storage.write(key: 'is_vault_only', value: value.toString());
    _isVaultOnly = value;
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

  Future<void> setVaultPin(String value) async {
    await _storage.write(key: 'vault_pin', value: value);
    _vaultPin = value;
    notifyListeners();
  }

  Future<bool> authenticatePin(String input) async {
    return _pin == input;
  }

  Future<bool> authenticateVaultPin(String input) async {
    return _vaultPin == input;
  }

  Future<bool> authenticateBiometric({String? localizedReason}) async {
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
        localizedReason: localizedReason ?? 'Please authenticate to access your finances',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
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
