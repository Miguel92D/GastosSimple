// Privacidad y seguridad (chat 05): PIN, huella, bloqueo tras varios PIN
// fallidos y consentimiento de Crashlytics (Especificación §9).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/i18n/app_translations.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/features/settings/screens/consent_screen.dart';
import 'package:gastos_simple/features/settings/screens/pin_screen.dart';
import 'package:gastos_simple/features/settings/screens/privacy_policy_screen.dart';
import 'package:gastos_simple/services/security_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: AppLocaleController.instance),
    ChangeNotifierProvider.value(value: AppState.instance),
    ChangeNotifierProvider.value(value: SecurityService.instance),
  ],
  child: MaterialApp(home: child),
);

String _t(String key) => AppLocaleController.instance.text(key);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PIN y bloqueo', () {
    late DateTime ahora;
    final security = SecurityService.instance;

    /// Teléfono con el PIN 1234 activo (y 5678 en la Bóveda).
    Future<void> conPin([Map<String, String> extra = const {}]) async {
      FlutterSecureStorage.setMockInitialValues({
        'is_pin_active': 'true',
        'pin': '1234',
        'is_vault_pin_active': 'true',
        'vault_pin': '5678',
        ...extra,
      });
      await security.reloadForTesting();
    }

    Future<void> fallar(int veces) async {
      for (var i = 0; i < veces; i++) {
        expect(await security.authenticatePin('0000'), isFalse);
      }
    }

    setUp(() async {
      ahora = DateTime(2026, 10, 5, 12);
      SecurityService.clock = () => ahora;
      SharedPreferences.setMockInitialValues({});
      await conPin();
    });

    tearDown(() => SecurityService.clock = DateTime.now);

    test('el PIN correcto entra y el incorrecto no', () async {
      expect(security.isPinActive, isTrue);
      expect(await security.authenticatePin('1234'), isTrue);
      expect(await security.authenticatePin('4321'), isFalse);
      expect(await security.authenticateVaultPin('5678'), isTrue);
      expect(await security.authenticateVaultPin('1234'), isFalse);
    });

    test('4 fallos no bloquean; el 5.º bloquea 30 s', () async {
      await fallar(SecurityService.freeAttempts - 1);
      expect(security.isLockedOut, isFalse);

      await fallar(1);
      expect(security.isLockedOut, isTrue);
      expect(security.lockRemaining, const Duration(seconds: 30));
    });

    test('bloqueado, ni el PIN correcto entra; al terminar sí', () async {
      await fallar(5);
      expect(await security.authenticatePin('1234'), isFalse);

      ahora = ahora.add(const Duration(seconds: 31));
      expect(security.isLockedOut, isFalse);
      expect(await security.authenticatePin('1234'), isTrue);

      // Entrar bien borra la cuenta: hacen falta otros 5 fallos.
      await fallar(4);
      expect(security.isLockedOut, isFalse);
    });

    test(
      'cada fallo después del bloqueo duplica la espera, hasta 15 min',
      () async {
        await fallar(5);
        final esperas = <Duration>[security.lockRemaining];
        for (var i = 0; i < 7; i++) {
          ahora = ahora.add(security.lockRemaining);
          await fallar(1);
          esperas.add(security.lockRemaining);
        }
        expect(esperas.map((d) => d.inSeconds), [
          30,
          60,
          120,
          240,
          480,
          900,
          900,
          900,
        ]);
      },
    );

    test('cerrar y abrir la app no saca el bloqueo', () async {
      await fallar(5);
      final guardado = await const FlutterSecureStorage().readAll();

      await conPin(guardado);

      expect(security.isLockedOut, isTrue);
      expect(await security.authenticatePin('1234'), isFalse);
    });

    test('el PIN de la Bóveda comparte el bloqueo', () async {
      await fallar(5);
      expect(await security.authenticateVaultPin('5678'), isFalse);
    });

    testWidgets('la pantalla de PIN avisa el error y el bloqueo', (
      tester,
    ) async {
      Future<void> tipear(String pin) async {
        for (final d in pin.split('')) {
          await tester.tap(find.text(d));
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(_app(const PinScreen()));
      // 9999: el aviso de abajo tapa el botón 0 en la pantalla del test.
      await tipear('9999');
      expect(find.text(_t('wrong_pin')), findsOneWidget);

      for (var i = 0; i < 4; i++) {
        await tipear('9999');
      }
      expect(find.textContaining('30 s'), findsOneWidget);
      expect(security.isUnlocked, isFalse);
    });
  });

  group('huella (D-035)', () {
    final security = SecurityService.instance;

    Future<void> telefono(Map<String, String> guardado) async {
      FlutterSecureStorage.setMockInitialValues(guardado);
      await security.reloadForTesting();
      security.lock();
    }

    setUp(() => SecurityService.deviceHasLock = () async => true);

    test('se prende sin PIN (solo huella)', () async {
      await telefono({});

      await security.setBiometricActive(true);
      expect(security.isBiometricActive, isTrue);
      expect(security.isPinActive, isFalse);
      expect(security.isBiometricOnly, isTrue);
      await security.reloadForTesting();
      expect(security.isBiometricActive, isTrue, reason: 'queda guardado');
    });

    test('apagar el PIN deja la huella prendida', () async {
      await telefono({
        'is_pin_active': 'true',
        'pin': '1234',
        'is_biometric_active': 'true',
      });
      expect(security.isBiometricOnly, isFalse);

      await security.setPinActive(false);
      expect(security.isBiometricActive, isTrue);
      expect(security.isBiometricOnly, isTrue);
    });

    test('solo PIN: la huella queda apagada', () async {
      await telefono({'is_pin_active': 'true', 'pin': '1234'});
      expect(security.isPinActive, isTrue);
      expect(security.isBiometricActive, isFalse);
    });

    test('solo huella y el teléfono con bloqueo: no se abre sola', () async {
      await telefono({'is_biometric_active': 'true'});

      expect(await security.releaseIfPhoneHasNoLock(), isFalse);
      expect(security.isUnlocked, isFalse);
      expect(security.isBiometricActive, isTrue);
    });

    test(
      'solo huella y el teléfono sin bloqueo: entra y apaga la huella',
      () async {
        await telefono({'is_biometric_active': 'true'});
        SecurityService.deviceHasLock = () async => false;

        expect(await security.releaseIfPhoneHasNoLock(), isTrue);
        expect(security.isUnlocked, isTrue);
        expect(security.isBiometricActive, isFalse);
        await security.reloadForTesting();
        expect(security.isBiometricActive, isFalse, reason: 'queda guardado');
      },
    );

    test('con PIN, aunque el teléfono no tenga bloqueo, pide el PIN', () async {
      await telefono({
        'is_pin_active': 'true',
        'pin': '1234',
        'is_biometric_active': 'true',
      });
      SecurityService.deviceHasLock = () async => false;

      expect(await security.releaseIfPhoneHasNoLock(), isFalse);
      expect(security.isUnlocked, isFalse);
    });

    testWidgets('solo huella: botón "Usar huella" y sin teclado', (
      tester,
    ) async {
      await telefono({'is_biometric_active': 'true'});

      await tester.pumpWidget(_app(const PinScreen()));
      await tester.pumpAndSettle();

      expect(find.text(_t('unlock_biometric_title')), findsOneWidget);
      expect(find.text(_t('use_biometric').toUpperCase()), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(security.isUnlocked, isFalse);
    });

    testWidgets('con PIN y huella se ve el teclado', (tester) async {
      await telefono({
        'is_pin_active': 'true',
        'pin': '1234',
        'is_biometric_active': 'true',
      });

      await tester.pumpWidget(_app(const PinScreen()));
      await tester.pumpAndSettle();

      expect(find.text(_t('enter_pin')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('solo huella sin bloqueo del teléfono: entra y avisa', (
      tester,
    ) async {
      await telefono({'is_biometric_active': 'true'});
      SecurityService.deviceHasLock = () async => false;

      await tester.pumpWidget(_app(const PinScreen()));
      await tester.pumpAndSettle();

      expect(security.isUnlocked, isTrue);
      expect(find.text(_t('biometric_off_no_lock')), findsOneWidget);
    });
  });

  group('consentimiento de Crashlytics', () {
    final pedidos = <bool>[];

    setUp(() {
      pedidos.clear();
      AppState.crashlyticsSwitch = (enabled) async => pedidos.add(enabled);
    });

    test('la primera vez arranca apagado', () async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.loadConsent();

      expect(AppState.instance.hasConsented, isFalse);
      expect(AppState.instance.crashReportsEnabled, isFalse);
      expect(pedidos, [false]);
    });

    test('solo se prende si el usuario acepta, y se puede apagar', () async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.loadConsent();

      await AppState.instance.setConsent(crashReports: true);
      expect(AppState.instance.crashReportsEnabled, isTrue);

      // Al volver a abrir la app se respeta lo que eligió.
      await AppState.instance.loadConsent();
      expect(pedidos, [false, true, true]);

      await AppState.instance.setConsent(crashReports: false);
      await AppState.instance.loadConsent();
      expect(pedidos.skip(3), [false, false]);
      expect(AppState.instance.crashReportsEnabled, isFalse);
    });

    testWidgets('"Continuar sin enviar reportes" deja Crashlytics apagado', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.loadConsent();
      await tester.pumpWidget(_app(const ConsentScreen()));

      await tester.tap(find.text(_t('consent_decline')));
      await tester.pumpAndSettle();

      expect(AppState.instance.hasConsented, isTrue);
      expect(AppState.instance.crashReportsEnabled, isFalse);
      expect(pedidos, everyElement(isFalse));
    });

    test('Android arranca con Crashlytics apagado (AndroidManifest)', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        RegExp(
          r'firebase_crashlytics_collection_enabled"\s*android:value="false"',
        ).hasMatch(manifest),
        isTrue,
      );
    });
  });

  group('política de privacidad y landing', () {
    String leer(String path) =>
        File(path).readAsStringSync().replaceAll('\r\n', '\n');

    /// Texto visible del HTML: sin etiquetas y con las entidades (&#243;)
    /// convertidas en letras.
    String texto(String html) => html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAllMapped(
          RegExp(r'&#(x?)([0-9a-fA-F]+);'),
          (m) => String.fromCharCode(
            int.parse(m[2]!, radix: m[1]!.isEmpty ? 10 : 16),
          ),
        )
        .replaceAll(RegExp(r'\s+'), ' ');

    test('las tres copias de la landing son iguales (Especificación §12)', () {
      for (final page in ['index.html', 'privacy.html']) {
        final docs = leer('docs/$page');
        expect(leer('github_pages_root/$page'), docs, reason: page);
        expect(leer('SimpleLanding/$page'), docs, reason: page);
      }
    });

    test('la app y la web dicen lo mismo, en los dos idiomas', () {
      final web = texto(leer('docs/privacy.html'));
      for (final lang in ['es', 'en']) {
        final t = AppTranslations.translations[lang]!;
        for (var i = 1; i <= PrivacyPolicyScreen.sectionCount; i++) {
          expect(web, contains('$i. ${t['privacy_s${i}_title']}'));
          expect(web, contains(t['privacy_s${i}_body']));
        }
      }
    });

    test('la web no promete lo que la app ya no tiene', () {
      final web = texto(leer('docs/index.html') + leer('docs/privacy.html'));
      for (final viejo in [
        'presupuestos',
        'budgets',
        'predicciones',
        'predictions',
        'nunca salen de tu dispositivo',
        'never leaves your device',
      ]) {
        expect(web.toLowerCase(), isNot(contains(viejo)), reason: viejo);
      }
    });
  });
}
