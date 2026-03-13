import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final symbol = symbolOverride ?? instance._currencySymbol;
    
    if (value.abs() >= 1000000000000) {
      final formatter = NumberFormat.compact();
      return '$symbol ${formatter.format(value)}';
    }

    final hasDecimals = value.abs() % 1 != 0;

    final formatter = NumberFormat.decimalPattern();
    if (hasDecimals) {
      formatter.minimumFractionDigits = 2;
      formatter.maximumFractionDigits = 2;
    } else {
      formatter.minimumFractionDigits = 0;
      formatter.maximumFractionDigits = 0;
    }

    String formatted = formatter.format(value);
    
    // Default style: Symbol + Space + Value
    final space = symbol.length > 1 ? ' ' : '';
    return '$symbol$space$formatted';
  }
}
