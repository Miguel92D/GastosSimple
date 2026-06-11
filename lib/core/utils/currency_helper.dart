import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/currency_service.dart';

class CurrencyHelper {
  static String format(double value, BuildContext context) {
    // Watching the service ensures the widget calling this rebuilds on currency change
    context.watch<CurrencyService>();
    return CurrencyService.format(value);
  }

  static String getSymbol(BuildContext context) {
    return context.watch<CurrencyService>().currencySymbol;
  }

  static double? parseAmount(String text) {
    final rawText = text.trim();
    if (rawText.isEmpty) return null;

    String cleanText = rawText.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (cleanText.isEmpty ||
        cleanText == '-' ||
        cleanText == ',' ||
        cleanText == '.') {
      return null;
    }

    final isNegative = cleanText.startsWith('-');
    cleanText = cleanText.replaceAll('-', '');
    if (cleanText.isEmpty) return null;

    final commaCount = ','.allMatches(cleanText).length;
    if (commaCount > 1) return null;

    final parts = cleanText.split(',');
    final wholePart = parts[0].replaceAll('.', '');
    if (wholePart.isEmpty || !RegExp(r'^\d+$').hasMatch(wholePart)) {
      return null;
    }

    var normalized = wholePart;
    if (parts.length == 2) {
      final decimalPart = parts[1];
      if (!RegExp(r'^\d{0,2}$').hasMatch(decimalPart)) return null;
      if (decimalPart.isNotEmpty) {
        normalized = '$normalized.$decimalPart';
      }
    }

    if (normalized.isEmpty || normalized == '.') return null;
    if (isNegative) normalized = '-$normalized';
    return double.tryParse(normalized);
  }

  static String formatAmountForInput(double value) {
    if (value == 0) return '';

    String asString = value.toStringAsFixed(2);
    List<String> parts = asString.split('.');
    String intPart = parts[0];
    String decPart = parts[1];

    // In Spanish locale (the default for this app currently), we use comma
    if (decPart == '00') {
      decPart = '';
    } else if (decPart.endsWith('0')) {
      decPart = decPart.substring(0, 1);
    }

    final bool isNegative = intPart.startsWith('-');
    final int stopIndex = isNegative ? 1 : 0;

    List<String> chars = intPart.split('');
    String formattedWhole = '';
    int count = 0;

    for (int i = chars.length - 1; i >= stopIndex; i--) {
      formattedWhole = chars[i] + formattedWhole;
      count++;
      if (count == 3 && i != stopIndex) {
        formattedWhole = '.$formattedWhole';
        count = 0;
      }
    }

    if (isNegative) {
      formattedWhole = '-$formattedWhole';
    }

    if (decPart.isNotEmpty) {
      return '$formattedWhole,$decPart';
    }
    return formattedWhole;
  }
}
