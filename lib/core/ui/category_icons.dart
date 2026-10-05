import 'package:flutter/material.dart';

/// Ícono de cada categoría. Única fuente para todas las pantallas (P-10):
/// "Agregar movimiento" y la lista de movimientos usan este mismo mapa.
///
/// Acepta el nombre guardado en la base en cualquiera de sus formas:
/// español (singular o plural, con o sin tilde), inglés o clave `cat_*`.
class CategoryIcons {
  CategoryIcons._();

  /// Ícono para una categoría que no está en la lista (por ejemplo, una
  /// escrita por el usuario).
  static const IconData fallback = Icons.category_rounded;

  static const Map<String, IconData> _byKey = {
    'cat_food': Icons.restaurant_rounded,
    'cat_transport': Icons.directions_bus_rounded,
    'cat_health': Icons.local_hospital_rounded,
    'cat_leisure': Icons.sports_esports_rounded,
    'cat_shopping': Icons.shopping_bag_rounded,
    'cat_subscriptions': Icons.subscriptions_rounded,
    'cat_services': Icons.receipt_long_rounded,
    'cat_credit_card': Icons.credit_card_rounded,
    'cat_loans': Icons.handshake_rounded,
    'cat_gift': Icons.card_giftcard_rounded,
    'cat_others': Icons.more_horiz_rounded,
    'cat_education': Icons.school_rounded,
    'cat_salary': Icons.payments_rounded,
    'cat_investment': Icons.trending_up_rounded,
    'cat_sale': Icons.sell_rounded,
    'cat_bonus': Icons.redeem_rounded,
  };

  /// Nombres guardados (sin tildes, en minúscula) → clave `cat_*`.
  static const Map<String, String> _aliases = {
    'comida': 'cat_food',
    'food': 'cat_food',
    'transporte': 'cat_transport',
    'transport': 'cat_transport',
    'salud': 'cat_health',
    'health': 'cat_health',
    'ocio': 'cat_leisure',
    'leisure': 'cat_leisure',
    'compras': 'cat_shopping',
    'shopping': 'cat_shopping',
    'suscripciones': 'cat_subscriptions',
    'subscriptions': 'cat_subscriptions',
    'servicios': 'cat_services',
    'services': 'cat_services',
    'tarjeta de credito': 'cat_credit_card',
    'credit card': 'cat_credit_card',
    'prestamos': 'cat_loans',
    'loans': 'cat_loans',
    'regalo': 'cat_gift',
    'regalos': 'cat_gift',
    'gift': 'cat_gift',
    'otros': 'cat_others',
    'others': 'cat_others',
    'educacion': 'cat_education',
    'education': 'cat_education',
    'salario': 'cat_salary',
    'salary': 'cat_salary',
    'inversion': 'cat_investment',
    'inversiones': 'cat_investment',
    'investment': 'cat_investment',
    'venta': 'cat_sale',
    'ventas': 'cat_sale',
    'sale': 'cat_sale',
    'bono': 'cat_bonus',
    'bonos': 'cat_bonus',
    'bonus': 'cat_bonus',
  };

  static IconData of(String category) {
    final key = _normalize(category);
    return _byKey[key] ?? _byKey[_aliases[key]] ?? fallback;
  }

  static String _normalize(String value) {
    const from = 'áéíóúü';
    const to = 'aeiouu';
    var result = value.trim().toLowerCase();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }
}
