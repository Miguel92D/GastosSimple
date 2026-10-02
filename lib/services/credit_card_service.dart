import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/card_schedule.dart';

/// Tarjetas guardadas para planes de cuotas (en SharedPreferences: entran
/// en el backup automático de Android).
class CreditCardService {
  CreditCardService._();

  static const _key = 'credit_cards';
  static const _lastKey = 'credit_card_last_used';

  static Future<List<CreditCard>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CreditCard.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<CreditCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(cards.map((c) => c.toJson()).toList()),
    );
  }

  static Future<CreditCard> addCard({
    required String name,
    required int closingDay,
    required int dueDay,
  }) async {
    final cards = await getCards();
    final card = CreditCard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      closingDay: closingDay,
      dueDay: dueDay,
    );
    await _save([...cards, card]);
    return card;
  }

  static Future<void> deleteCard(String id) async {
    final cards = await getCards();
    await _save(cards.where((c) => c.id != id).toList());
  }

  static Future<String?> getLastUsedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastKey);
  }

  static Future<void> setLastUsedId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_lastKey);
    } else {
      await prefs.setString(_lastKey, id);
    }
  }
}
