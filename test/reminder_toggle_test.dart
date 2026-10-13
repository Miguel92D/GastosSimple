import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/features/settings/screens/settings_screen.dart';
import 'package:gastos_simple/services/currency_service.dart';
import 'package:gastos_simple/services/notification_service.dart';
import 'package:gastos_simple/services/security_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// P-25: en la versión de la tienda el plugin de avisos fallaba al cancelar
/// o programar (Gson + R8). El error subía hasta Ajustes y el interruptor
/// no se movía hasta salir y volver a entrar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<String> calls;
  var pluginBroken = false;
  bool? permissionGranted = true;

  setUpAll(() async {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'initialize':
          return true;
        case 'requestNotificationsPermission':
          return permissionGranted;
        case 'cancel':
        case 'zonedSchedule':
          if (pluginBroken) {
            throw PlatformException(
              code: 'error',
              message: 'TypeToken must be created with a type argument',
            );
          }
          return null;
      }
      return null;
    });
    calls = [];
    await NotificationService.instance.init();
  });

  tearDownAll(() => messenger.setMockMethodCallHandler(channel, null));

  setUp(() {
    calls = [];
    pluginBroken = false;
    permissionGranted = true;
    SharedPreferences.setMockInitialValues({});
  });

  Future<bool> savedEnabled() async =>
      (await NotificationService.instance.getReminderSettings()).enabled;

  group('NotificationService.setReminderEnabled', () {
    test('apagar cancela el aviso y guarda apagado', () async {
      expect(await NotificationService.instance.setReminderEnabled(false), true);
      expect(calls, contains('cancel'));
      expect(await savedEnabled(), false);
    });

    test('apagar no tira error aunque el plugin falle', () async {
      pluginBroken = true;
      expect(await NotificationService.instance.setReminderEnabled(false), true);
      expect(await savedEnabled(), false);
    });

    test('prender no tira error aunque el plugin falle', () async {
      SharedPreferences.setMockInitialValues({'notifications_enabled': false});
      pluginBroken = true;
      expect(await NotificationService.instance.setReminderEnabled(true), true);
      expect(await savedEnabled(), true);
    });

    test('si se niega el permiso no se prende', () async {
      SharedPreferences.setMockInitialValues({'notifications_enabled': false});
      permissionGranted = false;
      expect(
        await NotificationService.instance.setReminderEnabled(true),
        false,
      );
      expect(await savedEnabled(), false);
    });
  });

  group('Interruptor en Ajustes', () {
    Widget buildSettings() => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppLocaleController.instance),
        ChangeNotifierProvider.value(value: AppState.instance),
        ChangeNotifierProvider.value(value: SecurityService.instance),
        ChangeNotifierProvider.value(value: CurrencyService.instance),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );

    Finder reminderSwitch() => find.descendant(
      of: find.ancestor(
        of: find.text(AppLocaleController.instance.text('reminder_daily')),
        matching: find.byType(InkWell),
      ),
      matching: find.byType(Switch),
    );

    // La pantalla tiene animaciones que no terminan: pumpAndSettle no sirve.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> showReminderSwitch(WidgetTester tester) async {
      await tester.pumpWidget(buildSettings());
      await settle(tester);
      await tester.scrollUntilVisible(
        reminderSwitch(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }

    testWidgets('se mueve al tocarlo aunque el plugin falle', (tester) async {
      pluginBroken = true;
      await showReminderSwitch(tester);
      expect(tester.widget<Switch>(reminderSwitch()).value, true);

      await tester.tap(reminderSwitch());
      await settle(tester);
      expect(tester.widget<Switch>(reminderSwitch()).value, false);
      expect(await savedEnabled(), false);

      await tester.tap(reminderSwitch());
      await settle(tester);
      expect(tester.widget<Switch>(reminderSwitch()).value, true);
      expect(await savedEnabled(), true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vuelve atrás si se niega el permiso', (tester) async {
      SharedPreferences.setMockInitialValues({'notifications_enabled': false});
      permissionGranted = false;
      await showReminderSwitch(tester);
      expect(tester.widget<Switch>(reminderSwitch()).value, false);

      await tester.tap(reminderSwitch());
      await settle(tester);
      expect(tester.widget<Switch>(reminderSwitch()).value, false);
      expect(
        find.text(AppLocaleController.instance.text('reminder_permission_denied')),
        findsOneWidget,
      );
    });
  });
}
