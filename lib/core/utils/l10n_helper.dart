import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class L10nHelper {
  static String getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return category;

    switch (category.toLowerCase()) {
      case 'comida':
        return l10n.cat_food;
      case 'transporte':
        return l10n.cat_transport;
      case 'ocio':
        return l10n.cat_leisure;
      case 'salud':
        return l10n.cat_health;
      case 'educación':
        return l10n.cat_education;
      case 'otros':
        return l10n.cat_others;
      case 'salario':
        return l10n.cat_salary;
      case 'venta':
        return l10n.cat_sale;
      case 'regalo':
        return l10n.cat_gift;
      case 'inversión':
        return l10n.cat_investment;
      default:
        return category;
    }
  }
}
