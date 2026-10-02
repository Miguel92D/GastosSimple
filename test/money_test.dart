import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/money.dart';

void main() {
  test('suma sin errores de punto flotante', () {
    expect(0.1 + 0.2 == 0.3, isFalse); // el problema
    expect(Money.sum([0.1, 0.2]), 0.3); // la solución
    expect(Money.sum(List.filled(1000, 0.1)), 100.0);
  });

  test('redondeo a centavos', () {
    expect(Money.round(33.333333), 33.33);
    expect(Money.round(1530.006), 1530.01);
    expect(Money.round(-12.346), -12.35);
  });

  test('cero con tolerancia de centavos', () {
    expect(Money.isZero(1000000 - 999999.9999999), isTrue);
    expect(Money.isZero(0.01), isFalse);
  });
}
