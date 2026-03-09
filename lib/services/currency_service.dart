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
    final hasDecimals = value.abs() % 1 != 0;

    // We use es_AR for grouping and decimal separators: . and ,
    final formatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: instance._currencySymbol,
      decimalDigits: hasDecimals ? 2 : 0,
    );

    String formatted = formatter.format(value);

    // If the formatter puts the symbol at the end, move it to the front
    if (formatted.contains(instance._currencySymbol)) {
      // Remove the symbol from wherever it is and put it at the start
      String numericPart = formatted
          .replaceAll(instance._currencySymbol, '')
          .trim();
      return '${instance._currencySymbol}$numericPart';
    }

    // If for some reason the symbol is missing, add it
    return '${instance._currencySymbol}$formatted';
  }
}
