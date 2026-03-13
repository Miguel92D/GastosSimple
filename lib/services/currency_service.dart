import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService extends ChangeNotifier {
  static final CurrencyService instance = CurrencyService._init();
  String _currencySymbol = r'$';

  CurrencyService._init();

  String get currencySymbol => _currencySymbol;

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString('currency_symbol') ?? r'$';
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    _currencySymbol = symbol;
    notifyListeners();
  }

  static String format(double value) {
    if (value.abs() >= 1000000000000) {
      // For extremely large numbers (>= 1 trillion), use compact format to avoid UI breakage
      final formatter = NumberFormat.compact(locale: 'es_AR');
      String formatted = formatter.format(value);
      return '${instance._currencySymbol} $formatted';
    }

    final hasDecimals = value.abs() % 1 != 0;

    final formatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: instance._currencySymbol,
      decimalDigits: hasDecimals ? 2 : 0,
    );

    String formatted = formatter.format(value);

    // If the formatter puts the symbol at the end, move it to the front
    if (formatted.contains(instance._currencySymbol)) {
      String numericPart = formatted
          .replaceAll(instance._currencySymbol, '')
          .trim();
      final space = instance._currencySymbol.length > 1 ? ' ' : '';
      return '${instance._currencySymbol}$space$numericPart';
    }

    final space = instance._currencySymbol.length > 1 ? ' ' : '';
    return '${instance._currencySymbol}$space$formatted';
  }
}
