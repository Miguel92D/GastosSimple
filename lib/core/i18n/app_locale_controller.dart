import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';

class AppLocaleController extends ChangeNotifier {
  String _locale = 'es';

  String get locale => _locale;

  AppLocaleController() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('language_code') ?? 'es';
    notifyListeners();
  }

  void changeLocale(String newLocale) async {
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale);
  }

  String text(String key, [Map<String, String>? params]) {
    String translation = AppTranslations.translations[_locale]?[key] ?? 
                         AppTranslations.translations['es']?[key] ?? 
                         key;
                         
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }
    
    return translation;
  }
}
