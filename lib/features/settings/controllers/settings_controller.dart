import '../../../core/i18n/app_locale_controller.dart';
import '../../../services/theme_service.dart';
import '../../../services/security_service.dart';
import '../../../services/currency_service.dart';

class SettingsController {
  static void toggleTheme() {
    ThemeService.instance.toggleTheme();
  }

  static void changeLanguage(String code) {
    AppLocaleController.instance.changeLocale(code);
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
