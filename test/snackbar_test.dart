// Avisos flotantes (P-22, chat 09): en una pantalla sin botones abajo el aviso
// tiene que verse adentro de la pantalla, no arriba del borde.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/ui/app_theme.dart';
import 'package:gastos_simple/core/ui/layout/app_scaffold.dart';

Future<void> _showAviso(WidgetTester tester, Widget? drawer) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.brandTheme,
      home: AppScaffold(
        title: 'Prueba',
        drawer: drawer,
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Aviso'))),
            child: const Text('Mostrar'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Mostrar'));
  await tester.pumpAndSettle();
}

void main() {
  for (final conMenu in [false, true]) {
    testWidgets(
      'el aviso se ve adentro de la pantalla (${conMenu ? 'con' : 'sin'} menú)',
      (tester) async {
        await _showAviso(tester, conMenu ? const Drawer() : null);
        expect(tester.takeException(), isNull);
        final rect = tester.getRect(find.byType(SnackBar));
        final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(screen.height));
        // Queda en la mitad de abajo, donde se espera un aviso.
        expect(rect.top, greaterThan(screen.height / 2));
      },
    );
  }
}
