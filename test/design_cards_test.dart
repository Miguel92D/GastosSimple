// Retoques visuales (chat 07): las tarjetas de Ingresos y Gastos del inicio
// se ven iguales aunque un monto sea mucho más largo que el otro.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/features/dashboard/widgets/income_expense_cards.dart';
import 'package:gastos_simple/services/currency_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget app(Widget child) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: AppLocaleController.instance),
      ChangeNotifierProvider.value(value: AppState.instance),
      ChangeNotifierProvider.value(value: CurrencyService.instance),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 600, child: child)),
      ),
    ),
  );

  Future<void> expectTwins(WidgetTester tester, double inc, double exp) async {
    await tester.pumpWidget(
      app(IncomeExpenseCards(income: inc, expenses: exp)),
    );
    final income = find.text(CurrencyService.format(inc));
    final expense = find.text(CurrencyService.format(exp));
    expect(income, findsOneWidget);
    expect(expense, findsOneWidget);

    // Mismo tamaño de letra en los dos montos.
    final incSize = tester.widget<Text>(income).style!.fontSize;
    final expSize = tester.widget<Text>(expense).style!.fontSize;
    expect(incSize, expSize);

    // Mismo alto en las dos tarjetas.
    final cards = find.byType(GestureDetector);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getSize(cards.at(0)).height,
      tester.getSize(cards.at(1)).height,
    );
  }

  testWidgets(
    'monto de ingresos muy largo y gastos corto (captura de Miguel)',
    (tester) async {
      await expectTwins(tester, 609099096909.60, 918);
    },
  );

  testWidgets('montos normales usan el tamaño completo', (tester) async {
    await expectTwins(tester, 1500, 918);
    final size = tester
        .widget<Text>(find.text(CurrencyService.format(918)))
        .style!
        .fontSize;
    expect(size, 20);
  });
}
