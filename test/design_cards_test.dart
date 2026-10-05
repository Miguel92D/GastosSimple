// Retoques visuales (chat 07): las tarjetas de Ingresos y Gastos del inicio
// se ven iguales aunque un monto sea mucho más largo que el otro.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/core/ui/app_text_styles.dart';
import 'package:gastos_simple/core/ui/widgets/balance_card.dart';
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

  testWidgets('el monto tiene siempre el mismo tamaño (D-030)', (tester) async {
    await expectTwins(tester, 1500, 918);
    final big = tester
        .widget<Text>(find.text(CurrencyService.format(1500)))
        .style!
        .fontSize;
    expect(big, AppTextStyles.amountCard.fontSize);
    final size = tester
        .widget<Text>(find.text(CurrencyService.format(918)))
        .style!
        .fontSize;
    expect(size, AppTextStyles.amountCard.fontSize);
  });

  testWidgets('el balance mide lo mismo con cualquier monto (D-030)', (
    tester,
  ) async {
    Future<double> heightFor(double balance) async {
      await tester.pumpWidget(
        app(BalanceCard(balance: balance, subtitle: 'Octubre 2026')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      return tester.getSize(find.byType(BalanceCard)).height;
    }

    final small = await heightFor(1530);
    final huge = await heightFor(609099095991.60);
    expect(huge, small);
  });

  testWidgets('Ingresos/Gastos miden lo mismo con cualquier monto (D-030)', (
    tester,
  ) async {
    Future<double> heightFor(double inc, double exp) async {
      await tester.pumpWidget(
        app(IncomeExpenseCards(income: inc, expenses: exp)),
      );
      return tester.getSize(find.byType(GestureDetector).first).height;
    }

    final small = await heightFor(5000, 3470);
    final huge = await heightFor(609099096909.60, 918);
    expect(huge, small);
  });

  group('reglas de diseño (D-029)', () {
    // Archivos donde sí se definen colores (tokens) o el tema claro sin uso.
    const tokenFiles = [
      'core/ui/app_colors.dart',
      'core/ui/app_gradients.dart',
      'core/ui/app_theme.dart',
    ];
    final materialColor = RegExp(
      r'Colors\.(deepPurple|orange|redAccent|green|red|blue|blueAccent|'
      r'purple|pink|teal|grey|yellow|amber|white70|white54|white38|black54|'
      r'black87)',
    );

    Iterable<File> screens() => Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) {
          final path = f.path.replaceAll('\\', '/');
          return !tokenFiles.any(path.endsWith);
        });

    test('ninguna pantalla escribe colores a mano', () {
      final offenders = <String>[];
      for (final f in screens()) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('Color(0x') || materialColor.hasMatch(line)) {
            offenders.add('${f.path}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
