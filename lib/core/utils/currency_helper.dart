import 'package:flutter/material.dart';
import '../../services/currency_service.dart';

class CurrencyHelper {
  static String format(double value, BuildContext context) {
    return CurrencyService.format(value);
  }

  static String getSymbol(BuildContext context) {
    return CurrencyService.instance.currencySymbol;
  }
}
