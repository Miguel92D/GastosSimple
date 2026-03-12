import 'package:flutter/material.dart';
import '../i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';

class L10nHelper {
  static String getLocalizedCategory(BuildContext context, String category) {
    final l10n = context.read<AppLocaleController>();
    if (l10n == null) return category;

    switch (category.toLowerCase()) {
      case 'comida':
      case 'cat_food':
        return l10n.text('cat_food');
      case 'transporte':
      case 'cat_transport':
        return l10n.text('cat_transport');
      case 'ocio':
      case 'cat_leisure':
        return l10n.text('cat_leisure');
      case 'salud':
      case 'cat_health':
        return l10n.text('cat_health');
      case 'educación':
      case 'cat_education':
        return l10n.text('cat_education');
      case 'otros':
      case 'cat_others':
        return l10n.text('cat_others');
      case 'salario':
      case 'cat_salary':
        return l10n.text('cat_salary');
      case 'venta':
      case 'cat_sale':
        return l10n.text('cat_sale');
      case 'regalo':
      case 'cat_gift':
        return l10n.text('cat_gift');
      case 'inversión':
      case 'cat_investment':
        return l10n.text('cat_investment');
      default:
        return category;
    }
  }
}
