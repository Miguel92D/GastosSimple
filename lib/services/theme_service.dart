import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._init();
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeService._init();

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    // Already forced to dark
  }

  Future<void> toggleTheme() async {
    // Already forced to dark
  }
}

