import '../../../services/theme_service.dart';
import '../../../services/language_service.dart';
import '../../../services/security_service.dart';
import '../../../services/currency_service.dart';

class SettingsController {
  static void toggleTheme() {
    ThemeService.instance.toggleTheme();
  }

  static void changeLanguage(String code) {
    LanguageService.instance.setLocale(code);
  }

  static void changeCurrency(String currency) {
    CurrencyService.instance.setCurrency(currency);
  }

  static void enablePin(bool value) {
    SecurityService.instance.setPinActive(value);
  }

  static void enableBiometric(bool value) {
    SecurityService.instance.setBiometricActive(value);
  }
}
