import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCurrency {
  final String code;
  final String name;
  final String symbol;

  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class CurrencyService extends ChangeNotifier {
  static final CurrencyService instance = CurrencyService._init();
  String _currencySymbol = r'$';
  String _currencyCode = 'USD';

  CurrencyService._init();

  String get currencySymbol => _currencySymbol;
  String get currencyCode => _currencyCode;

  AppCurrency get selectedCurrency => availableCurrencies.firstWhere(
    (c) => c.code == _currencyCode,
    orElse: () => availableCurrencies[0],
  );

  static const List<AppCurrency> availableCurrencies = [
    AppCurrency(code: 'USD', name: 'US Dollar', symbol: r'$'),
    AppCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
    AppCurrency(code: 'ARS', name: 'Peso Argentino', symbol: r'$'),
    AppCurrency(code: 'MXN', name: 'Peso Mexicano', symbol: r'$'),
    AppCurrency(code: 'COP', name: 'Peso Colombiano', symbol: r'$'),
    AppCurrency(code: 'CLP', name: 'Peso Chileno', symbol: r'$'),
    AppCurrency(code: 'BRL', name: 'Real Brasileiro', symbol: 'R\$'),
    AppCurrency(code: 'PYG', name: 'Guaraní Paraguayo', symbol: '₲'),
    AppCurrency(code: 'PEN', name: 'Sol Peruano', symbol: 'S/'),
    AppCurrency(code: 'UYU', name: 'Peso Uruguayo', symbol: r'$U'),
    AppCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
    AppCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  ];

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString('currency_symbol') ?? r'$';
    _currencyCode = prefs.getString('currency_code') ?? 'USD';
    notifyListeners();
  }

  Future<void> setCurrency(String symbol, [String? code]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    if (code != null) {
      await prefs.setString('currency_code', code);
      _currencyCode = code;
    }
    _currencySymbol = symbol;
    notifyListeners();
  }

  static String format(double value, {String? symbolOverride}) {
    return formatArgentineCurrency(value, symbolOverride: symbolOverride);
  }

  static String formatArgentineCurrency(
    double value, {
    String? symbolOverride,
  }) {
    final symbol = symbolOverride ?? instance._currencySymbol;
    final cents = (value.abs() * 100).round();
    final wholePart = cents ~/ 100;
    final decimalPart = cents % 100;
    final sign = value.isNegative && cents != 0 ? '-' : '';
    final decimals = decimalPart == 0
        ? ''
        : ',${decimalPart.toString().padLeft(2, '0')}';

    return '$symbol $sign${_formatWholePart(wholePart)}$decimals';
  }

  static String _formatWholePart(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
