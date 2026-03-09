import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._init();
  Locale _locale = const Locale('es');

  LanguageService._init() {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString('language_code') ?? 'es';
    if (langCode != 'es' && langCode != 'en') {
      langCode = 'es';
    }
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLocale(String langCode) async {
    if (langCode != 'es' && langCode != 'en') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    _locale = Locale(langCode);
    notifyListeners();
  }
}
