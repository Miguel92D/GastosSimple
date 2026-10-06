import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isInitialized = false;
  bool _isPinPromptVisible = false;
  final Completer<void> _initCompleter = Completer<void>();

  static const _screenChannel = MethodChannel('simple/screen_security');

  /// Bloqueo progresivo contra fuerza bruta (compartido por PIN y PIN de
  /// Bóveda). Tras [freeAttempts] fallos: 30 s, 60 s, 120 s... hasta 15 min.
  /// Se persiste para que cerrar y abrir la app no lo resetee.
  static const int freeAttempts = 5;
  static const Duration maxLockout = Duration(minutes: 15);
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  /// Solo para tests: reloj para probar el bloqueo sin esperar.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  /// ¿El teléfono tiene algún bloqueo (patrón, PIN, huella)? Se cambia en
  /// los tests. Si la consulta falla se responde "sí" para no abrir la app.
  @visibleForTesting
  static Future<bool> Function() deviceHasLock = () async {
    try {
      return await LocalAuthentication().isDeviceSupported();
    } catch (_) {
      return true;
    }
  };

  /// Solo para tests: vuelve a leer todo del almacenamiento seguro.
  @visibleForTesting
  Future<void> reloadForTesting() => _loadSecuritySettings();

  Future<void> get initialized => _initCompleter.future;
  bool get isInitialized => _isInitialized;

  /// Indica si una pantalla de PIN de la app está visible ahora mismo.
  /// Estado transitorio (no se persiste); evita apilar pantallas de PIN
  /// cuando la app vuelve del background varias veces seguidas.
  bool get isPinPromptVisible => _isPinPromptVisible;

  void setPinPromptVisible(bool value) {
    _isPinPromptVisible = value;
  }

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
    try {
      _isPinActive = (await _storage.read(key: 'is_pin_active')) == 'true';
      _isBiometricActive =
          (await _storage.read(key: 'is_biometric_active')) == 'true';
      _isVaultOnly = (await _storage.read(key: 'is_vault_only')) == 'true';
      _isVaultPinActive =
          (await _storage.read(key: 'is_vault_pin_active')) == 'true';
      _pin = await _storage.read(key: 'pin');
      _vaultPin = await _storage.read(key: 'vault_pin');
      _failedAttempts =
          int.tryParse(await _storage.read(key: 'pin_failed_attempts') ?? '') ??
          0;
      final lockedMs = int.tryParse(
        await _storage.read(key: 'pin_locked_until') ?? '',
      );
      _lockedUntil = lockedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lockedMs);
    } catch (e) {
      // Si el almacenamiento seguro no se puede leer (p. ej. datos
      // restaurados en otro teléfono), la app NO debe quedar colgada en el
      // spinner de InitialGuard: arranca sin seguridad configurada.
      debugPrint('Security: no se pudo leer el almacenamiento seguro: $e');
    } finally {
      _isInitialized = true;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      notifyListeners();
      _applyScreenSecurity();
    }
  }

  /// FLAG_SECURE en Android mientras haya algún bloqueo configurado.
  Future<void> _applyScreenSecurity() async {
    final secure = _isPinActive || _isBiometricActive || _isVaultPinActive;
    try {
      await _screenChannel.invokeMethod('setSecure', {'secure': secure});
    } catch (_) {
      // iOS / otras plataformas: no implementado, se ignora.
    }
  }

  /// Tiempo que falta para poder volver a intentar un PIN (cero si no hay
  /// bloqueo).
  Duration get lockRemaining {
    final until = _lockedUntil;
    if (until == null) return Duration.zero;
    final remaining = until.difference(clock());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isLockedOut => lockRemaining > Duration.zero;

  Future<bool> _checkPin(String? expected, String input) async {
    if (isLockedOut) return false;
    final ok = expected != null && expected.isNotEmpty && expected == input;
    if (ok) {
      _failedAttempts = 0;
      _lockedUntil = null;
      await _storage.delete(key: 'pin_failed_attempts');
      await _storage.delete(key: 'pin_locked_until');
    } else {
      _failedAttempts++;
      if (_failedAttempts >= freeAttempts) {
        final exp = _failedAttempts - freeAttempts; // 0, 1, 2...
        final seconds = 30 * (1 << (exp > 10 ? 10 : exp));
        final lock = Duration(seconds: seconds) > maxLockout
            ? maxLockout
            : Duration(seconds: seconds);
        _lockedUntil = clock().add(lock);
        await _storage.write(
          key: 'pin_locked_until',
          value: _lockedUntil!.millisecondsSinceEpoch.toString(),
        );
      }
      await _storage.write(
        key: 'pin_failed_attempts',
        value: _failedAttempts.toString(),
      );
    }
    notifyListeners();
    return ok;
  }

  Future<void> setPinActive(bool value) async {
    await _storage.write(key: 'is_pin_active', value: value.toString());
    _isPinActive = value;
    notifyListeners();
    _applyScreenSecurity();
  }

  Future<void> setVaultPinActive(bool value) async {
    await _storage.write(key: 'is_vault_pin_active', value: value.toString());
    _isVaultPinActive = value;
    notifyListeners();
    _applyScreenSecurity();
  }

  Future<void> setVaultOnly(bool value) async {
    await _storage.write(key: 'is_vault_only', value: value.toString());
    _isVaultOnly = value;
    notifyListeners();
  }

  /// PIN y huella se eligen por separado (D-035): la huella no necesita PIN.
  /// Su repuesto es el bloqueo del teléfono.
  Future<void> setBiometricActive(bool value) async {
    await _storage.write(key: 'is_biometric_active', value: value.toString());
    _isBiometricActive = value;
    notifyListeners();
    _applyScreenSecurity();
  }

  /// Hay huella sin PIN (solo huella).
  bool get isBiometricOnly => _isBiometricActive && !(_isPinActive && hasPin);

  /// Solo huella y el teléfono ya no tiene ningún bloqueo: Android borró las
  /// huellas y no hay con qué comprobar quién es. Sacar el bloqueo del
  /// teléfono exige conocerlo, así que se deja entrar y se apaga la huella
  /// (D-035). Devuelve true si pasó eso.
  Future<bool> releaseIfPhoneHasNoLock() async {
    if (!isBiometricOnly) return false;
    if (await deviceHasLock()) return false;
    await setBiometricActive(false);
    unlock();
    return true;
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

  Future<bool> authenticatePin(String input) => _checkPin(_pin, input);

  Future<bool> authenticateVaultPin(String input) =>
      _checkPin(_vaultPin, input);

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
        localizedReason:
            localizedReason ?? 'Please authenticate to access your finances',
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
