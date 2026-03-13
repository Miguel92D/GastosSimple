import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('l10n') || file.path.contains('i18n')) continue;
    
    String content = await file.readAsString();
    final original = content;

    content = content.replaceAll("AppLocalizations l10n", "AppLocaleController l10n");
    content = content.replaceAll("AppLocalizations.of(context)!", "context.watch<AppLocaleController>()");
    content = content.replaceAll("AppLocalizations.of(context)", "context.watch<AppLocaleController>()");
    content = content.replaceAll(RegExp(r'AppLocalizations\.of\(\s*context\s*\)!?'), "context.watch<AppLocaleController>()");

    // Replace l10n.property
    content = content.replaceAllMapped(RegExp(r'\bl10n\.([a-zA-Z0-9_]+)(?!\()'), (m) {
      if (m[1] == 'text') return m[0]!; // prevent l10n.text
      if (m[1] == 'locale') return m[0]!; // prevent l10n.locale
      if (m[1] == 'changeLocale') return m[0]!; 
      return "l10n.text('${m[1]!}')";
    });

    // Replace l10n.method(args)
    final methods1 = ['days_count', 'closing_day', 'snowball_method', 'interest_annual', 'remaining_amount', 'min_pay_amount', 'budget_title', 'top_category_insight', 'payment_amount_for'];
    for (final m in methods1) {
      final arg = (m == 'days_count') ? 'count' : (m == 'closing_day') ? 'day' : (m == 'snowball_method') ? 'name' : (m == 'interest_annual') ? 'rate' : (m.contains('amount') ? 'amount' : (m.contains('budget') || m.contains('top') ? 'category' : 'name'));
      content = content.replaceAllMapped(RegExp(r'\bl10n\.' + m + r'\(([^)]+)\)'), (match) {
        return "l10n.text('$m', {'$arg': ${match[1]}.toString()})";
      });
    }

    content = content.replaceAllMapped(RegExp(r'\bl10n\.priority_tip\(([^,]+),\s*([^)]+)\)'), (m) {
      return "l10n.text('priority_tip', {'name': ${m[1]}.toString(), 'rate': ${m[2]}.toString()})";
    });

    content = content.replaceAllMapped(RegExp(r'\bl10n\.extra_payment_tip\(([^,]+),\s*([^,]+),\s*([^)]+)\)'), (m) {
      return "l10n.text('extra_payment_tip', {'amount': ${m[1]}.toString(), 'name': ${m[2]}.toString(), 'months': ${m[3]}.toString()})";
    });

    if (content != original) {
      // Add imports
      if (!content.contains("package:provider/provider.dart")) {
        content = "import 'package:provider/provider.dart';\n$content";
      }
      if (!content.contains("package:gastos_simple/core/i18n/app_locale_controller.dart")) {
        content = "import 'package:gastos_simple/core/i18n/app_locale_controller.dart';\n$content";
      }
      await file.writeAsString(content);
      print('Updated ${file.path}');
    }
  }
}
