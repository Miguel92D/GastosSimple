import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GastosSimpleApp());
    expect(find.text('Gastos Simple'), findsOneWidget);
  });
}
