import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('l10n') || file.path.contains('i18n')) continue;
    
    String content = await file.readAsString();
    final original = content;

    // Remove imports
    content = content.replaceAll(RegExp("import\\s+.*?.(app_localizations|gen_l10n|flutter_gen).*\\.dart['\\\"][^;]*;"), "");

    // 1. Properties
    content = content.replaceAllMapped(RegExp(r'AppLocalizations\.of\(context\)!\.([a-zA-Z0-9_]+)(?!\()'), (m) {
      return "context.watch<AppLocaleController>().text('${m[1]!}')";
    });

    // 2. Methods 1 arg
    final methods1 = ['days_count', 'closing_day', 'snowball_method', 'interest_annual', 'remaining_amount', 'min_pay_amount', 'budget_title', 'top_category_insight', 'payment_amount_for'];
    for (final m in methods1) {
      final arg = (m == 'days_count') ? 'count' : (m == 'closing_day') ? 'day' : (m == 'snowball_method') ? 'name' : (m == 'interest_annual') ? 'rate' : (m.contains('amount') ? 'amount' : (m.contains('budget') || m.contains('top') ? 'category' : 'name'));
      content = content.replaceAllMapped(RegExp(r'AppLocalizations\.of\(context\)!\.' + m + r'\(([^)]+)\)'), (match) {
        return "context.watch<AppLocaleController>().text('$m', {'$arg': ${match[1]}.toString()})";
      });
    }

    // 3. Methods 2 args (priority_tip)
    content = content.replaceAllMapped(RegExp(r'AppLocalizations\.of\(context\)!\.priority_tip\(([^,]+),\s*([^)]+)\)'), (m) {
      return "context.watch<AppLocaleController>().text('priority_tip', {'name': ${m[1]}.toString(), 'rate': ${m[2]}.toString()})";
    });

    // 4. Methods 3 args (extra_payment_tip)
    content = content.replaceAllMapped(RegExp(r'AppLocalizations\.of\(context\)!\.extra_payment_tip\(([^,]+),\s*([^,]+),\s*([^)]+)\)'), (m) {
      return "context.watch<AppLocaleController>().text('extra_payment_tip', {'amount': ${m[1]}.toString(), 'name': ${m[2]}.toString(), 'months': ${m[3]}.toString()})";
    });

    if (content != original) {
      // Add imports
      if (!content.contains("package:provider/provider.dart")) {
        content = "import 'package:provider/provider.dart';\n" + content;
      }
      if (!content.contains("package:gastos_simple/core/i18n/app_locale_controller.dart")) {
        content = "import 'package:gastos_simple/core/i18n/app_locale_controller.dart';\n" + content;
      }
      await file.writeAsString(content);
      print('Updated ${file.path}');
    }
  }
}
