import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/main.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/core/ui/widgets/gold_shimmer_text.dart';

void main() {
  testWidgets('Smoke Test: App starts and displays Logo', (
    WidgetTester tester,
  ) async {
    // Force Pro status for the test
    AppState.instance.setPro(true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const GastosSimpleApp());

    // Verify that $imple logo is present (using GoldShimmerText)
    expect(find.byType(GoldShimmerText), findsOneWidget);

    // Verify PRO status is reflected
    expect(AppState.instance.isPro, true);
  });
}
