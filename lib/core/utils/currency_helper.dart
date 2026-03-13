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
}
