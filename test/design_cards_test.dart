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
    // Archivos donde sí se definen colores (tokens).
    const tokenFiles = [
      'core/ui/app_colors.dart',
      'core/ui/app_gradients.dart',
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

    test('no hay flechas de subida ni bajada (D-031)', () {
      // La Proyección y el Análisis mensual están ocultos (D-013).
      const hidden = ['monthly_analysis_screen.dart', 'prediction_screen.dart'];
      final arrow = RegExp(r'Icons\.(arrow_upward|arrow_downward)');
      final offenders = screens()
          .where((f) => !hidden.any(f.path.endsWith))
          .where((f) => arrow.hasMatch(f.readAsStringSync()))
          .map((f) => f.path);
      expect(offenders, isEmpty);
    });

    test('los íconos salen de AppIcons o CategoryIcons (R-3, D-032)', () {
      const catalogs = ['core/ui/app_icons.dart', 'core/ui/category_icons.dart'];
      final rawIcon = RegExp(r'(?<![A-Za-z_])Icons\.');
      final offenders = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) {
            final path = f.path.replaceAll('\\', '/');
            return !catalogs.any(path.endsWith);
          })) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (rawIcon.hasMatch(lines[i])) offenders.add('${f.path}:${i + 1}');
        }
      }
      expect(offenders, isEmpty);
    });

    // ── R-5 / R-7 (chat 08): las pantallas no dibujan a mano ──
    // Pantallas = lib/features y lib/core/flow. Los módulos viven en
    // lib/core/ui y ahí sí se definen medidas.
    Iterable<File> featureFiles() => Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) {
          final path = f.path.replaceAll('\\', '/');
          return path.contains('lib/features/') ||
              path.contains('lib/core/flow/');
        });

    List<String> offendersOf(RegExp rule) {
      final offenders = <String>[];
      for (final f in featureFiles()) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trimLeft();
          if (line.startsWith('//') || line.startsWith('*')) continue;
          if (rule.hasMatch(line)) offenders.add('${f.path}:${i + 1}');
        }
      }
      return offenders;
    }

    test('ninguna pantalla escribe un tamaño de letra o TextStyle (R-5)', () {
      expect(offendersOf(RegExp(r'fontSize: ?[0-9]|TextStyle\(')), isEmpty);
    });

    test('ninguna pantalla escribe un radio con número (R-5)', () {
      expect(offendersOf(RegExp(r'Radius\.circular\([0-9]')), isEmpty);
    });

    test('paneles, barras y botones salen de sus módulos (R-1)', () {
      // AppSheet, AppProgressBar, GradientButton / AppSecondaryButton.
      expect(
        offendersOf(
          RegExp(
            r'showModalBottomSheet|LinearProgressIndicator|ElevatedButton|'
            r'OutlinedButton',
          ),
        ),
        isEmpty,
      );
    });

    test('decoraciones a mano: solo las que quedan, y no crecen (R-1)', () {
      // Cosas que existen en una sola pantalla. La lista solo se achica.
      const allowed = {
        'debt_screen.dart': 5, // resumen, estrategias, etiqueta de deuda
        'transaction_tile.dart': 3, // fondos al deslizar
        'stats_screen.dart': 2, // puntos de color del gráfico
        'pin_screen.dart': 2, // teclado del PIN
        'premium_screen.dart': 2, // brillo del ícono, "mejor valor"
        'prediction_screen.dart': 2, // oculta (D-013)
        'add_transaction_screen.dart': 1, // botón de categoría
        'savings_goals_screen.dart': 1, // elegir emoji
        'consent_screen.dart': 1, // fondo de la primera pantalla
      };
      final counts = <String, int>{};
      for (final o in offendersOf(RegExp(r'BoxDecoration\('))) {
        final name = o.replaceAll('\\', '/').split('/').last.split(':').first;
        counts[name] = (counts[name] ?? 0) + 1;
      }
      for (final e in counts.entries) {
        expect(e.value, lessThanOrEqualTo(allowed[e.key] ?? 0), reason: e.key);
      }
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
