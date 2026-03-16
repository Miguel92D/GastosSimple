import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/app_locale_controller.dart';
import 'package:intl/intl.dart';

class L10nHelper {
  static String getLocalizedDateMonth(BuildContext context, DateTime date) {
    final l10n = context.read<AppLocaleController>();
    final formatted = DateFormat('MMMM yyyy', l10n.locale).format(date);
    if (formatted.isEmpty) return formatted;
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  static String getLocalizedCategory(BuildContext context, String category) {
    final l10n = context.read<AppLocaleController>();

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
      case 'ventas':
      case 'cat_sale':
        return l10n.text('cat_sale');
      case 'regalo':
      case 'regalos':
      case 'cat_gift':
        return l10n.text('cat_gift');
      case 'inversión':
      case 'inversion':
      case 'inversiones':
      case 'cat_investment':
        return l10n.text('cat_investment');
      case 'compras':
      case 'cat_shopping':
        return l10n.text('cat_shopping');
      case 'suscripciones':
      case 'cat_subscriptions':
        return l10n.text('cat_subscriptions');
      case 'servicios':
      case 'cat_services':
        return l10n.text('cat_services');
      case 'tarjeta de crédito':
      case 'cat_credit_card':
        return l10n.text('cat_credit_card');
      case 'préstamos':
      case 'cat_loans':
        return l10n.text('cat_loans');
      case 'bonos':
      case 'bono':
      case 'bonus':
      case 'cat_bonus':
        return l10n.text('cat_bonus');
      default:
        return category;
    }
  }
}
