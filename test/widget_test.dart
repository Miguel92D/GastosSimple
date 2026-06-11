import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/state/app_mode_controller.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/core/state/month_controller.dart';
import 'package:gastos_simple/main.dart';
import 'package:gastos_simple/services/currency_service.dart';
import 'package:gastos_simple/services/pro_service.dart';
import 'package:gastos_simple/services/security_service.dart';
import 'package:gastos_simple/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalErrorWidgetBuilder = ErrorWidget.builder;

  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppLocaleController.instance),
        ChangeNotifierProvider.value(value: AppState.instance),
        ChangeNotifierProvider.value(value: ThemeService.instance),
        ChangeNotifierProvider.value(value: SecurityService.instance),
        ChangeNotifierProvider.value(value: CurrencyService.instance),
        ChangeNotifierProvider.value(value: ProService.instance),
        ChangeNotifierProvider.value(value: AppModeController.instance),
        ChangeNotifierProvider.value(value: MonthController.instance),
      ],
      child: const GastosSimpleApp(),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppState.instance.setPro(false);
  });

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    ErrorWidget.builder = originalErrorWidgetBuilder;
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
