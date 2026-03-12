import 'dart:io';

void main() {
  final files = [
    'lib/features/debts/screens/debt_screen.dart',
    'lib/features/budgets/screens/budget_screen.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    
    // Replace imports
    content = content.replaceAll(
      "import '../../../l10n/app_localizations.dart';",
      "import '../../../core/i18n/app_locale_controller.dart';\nimport 'package:provider/provider.dart';"
    );
    content = content.replaceAll(
      "import '../../l10n/app_localizations.dart';",
      "import '../../../core/i18n/app_locale_controller.dart';\nimport 'package:provider/provider.dart';"
    );

    // Replace l10n definitions
    content = content.replaceAll(
      "final l10n = AppLocalizations.of(context)!;",
      "final l10n = context.watch<AppLocaleController>();"
    );
    content = content.replaceAll(
      "final innerL10n = AppLocalizations.of(context)!;",
      "final innerL10n = context.read<AppLocaleController>();"
    );
    content = content.replaceAll(
      "AppLocalizations.of(context)!",
      "context.read<AppLocaleController>()"
    );

    // Use regex to catch property access and convert to .text() calls
    // This is tricky as AppLocalizations properties are numerous.
    // Instead of property access, let's use a simpler approach of replacing common patterns found.

    // Specific replacements for DebtScreen properties
    final keys = [
      'new_debt', 'edit_debt', 'debt_name_label', 'total_amount', 'min_payment', 
      'interest_rate_optional', 'due_day_label', 'save_debt', 'complete_name_and_amount',
      'no_debts_empty', 'no_debts_subtitle', 'add_first_debt', 'payment_amount_hint',
      'confirm_payment', 'paid_label', 'debts', 'budgets', 'not_set'
    ];

    for (final key in keys) {
      content = content.replaceAll("l10n.$key", "l10n.text('$key')");
      content = content.replaceAll("innerL10n.$key", "innerL10n.text('$key')");
    }

    // Special cases with parameters
    content = content.replaceAll(
      RegExp(r"innerL10n\.payment_amount_for\(([^)]+)\)"),
      "innerL10n.text('payment_amount_for', {'name': \$1})"
    );
    content = content.replaceAll(
      RegExp(r"innerL10n\.complete_name_and_amount\(([^,]+),\s*([^)]+)\)"),
      "innerL10n.text('complete_name_and_amount', {'name': \$1, 'amount': \$2})"
    );
    content = content.replaceAll(
      RegExp(r"AppLocalizations\.of\(context\)!\.budget_title\(([^)]+)\)"),
      "context.watch<AppLocaleController>().text('budget_title', {'category': \$1})"
    );

    file.writeAsStringSync(content);
  }
  
  print('Refactor complete for debts and budgets');
}
