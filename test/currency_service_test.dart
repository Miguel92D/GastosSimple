import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:gastos_simple/core/utils/currency_helper.dart';
import 'package:gastos_simple/core/utils/currency_input_formatter.dart';
import 'package:gastos_simple/services/currency_service.dart';

void main() {
  test('formats integer amounts with Argentine thousands separator', () {
    expect(CurrencyService.format(68080, symbolOverride: r'$'), r'$ 68.080');
    expect(
      CurrencyService.formatArgentineCurrency(68080, symbolOverride: r'$'),
      r'$ 68.080',
    );
    expect(
      CurrencyService.formatArgentineCurrency(1530, symbolOverride: r'$'),
      r'$ 1.530',
    );
    expect(
      CurrencyService.formatArgentineCurrency(5082, symbolOverride: r'$'),
      r'$ 5.082',
    );
    expect(
      CurrencyService.formatArgentineCurrency(0, symbolOverride: r'$'),
      r'$ 0',
    );
  });

  test('formats decimal amounts with Argentine decimal comma', () {
    expect(
      CurrencyService.formatArgentineCurrency(599100.30, symbolOverride: r'$'),
      r'$ 599.100,30',
    );
    expect(
      CurrencyService.formatArgentineCurrency(900.60, symbolOverride: r'$'),
      r'$ 900,60',
    );
    expect(
      CurrencyService.formatArgentineCurrency(4135.80, symbolOverride: r'$'),
      r'$ 4.135,80',
    );
    expect(
      CurrencyService.formatArgentineCurrency(4135.8, symbolOverride: r'$'),
      r'$ 4.135,80',
    );
  });

  test('formats required release examples with Argentine separators', () {
    expect(
      CurrencyService.formatArgentineCurrency(599100.30, symbolOverride: r'$'),
      r'$ 599.100,30',
    );
    expect(
      CurrencyService.formatArgentineCurrency(600000, symbolOverride: r'$'),
      r'$ 600.000',
    );
    expect(
      CurrencyService.formatArgentineCurrency(900.60, symbolOverride: r'$'),
      r'$ 900,60',
    );
    expect(
      CurrencyService.formatArgentineCurrency(1530, symbolOverride: r'$'),
      r'$ 1.530',
    );
    expect(
      CurrencyService.formatArgentineCurrency(0, symbolOverride: r'$'),
      r'$ 0',
    );
  });

  test('parses Argentine input amounts', () {
    expect(CurrencyHelper.parseAmount('600.000'), 600000);
    expect(CurrencyHelper.parseAmount('900,60'), 900.60);
    expect(CurrencyHelper.parseAmount('599.100,30'), 599100.30);
  });

  test('input formatter keeps dots for thousands and comma for cents', () {
    final formatter = CurrencyInputFormatter();

    expect(
      formatter
          .formatEditUpdate(
            const TextEditingValue(),
            const TextEditingValue(
              text: '600000',
              selection: TextSelection.collapsed(offset: 6),
            ),
          )
          .text,
      '600.000',
    );
    expect(
      formatter
          .formatEditUpdate(
            const TextEditingValue(),
            const TextEditingValue(
              text: '900,60',
              selection: TextSelection.collapsed(offset: 6),
            ),
          )
          .text,
      '900,60',
    );
  });
}
