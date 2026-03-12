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
    
    // 1. Fix Imports
    content = content.replaceAll(
      "import '../../../l10n/app_localizations.dart';",
      "import '../../../core/i18n/app_locale_controller.dart';\nimport 'package:provider/provider.dart';"
    );
     content = content.replaceAll(
      "import '../../l10n/app_localizations.dart';",
      "import '../../../core/i18n/app_locale_controller.dart';\nimport 'package:provider/provider.dart';"
    );

    // 2. Fix variable declarations
    content = content.replaceAll(
      RegExp(r"(final|var)\s+(l10n|innerL10n)\s*=\s*AppLocalizations\.of\(context\)!;"),
      "\$1 \$2 = context.watch<AppLocaleController>();"
    );
    
    // 3. Fix direct uses in build / context.read
    content = content.replaceAll(
      "AppLocalizations.of(context)!",
      "context.read<AppLocaleController>()"
    );

    // 4. Transform property access into .text() calls
    // Handle both variable access and direct context.read calls
    content = content.replaceAllMapped(
      RegExp(r"(l10n|innerL10n|context\.read<AppLocaleController>\(\)|context\.watch<AppLocaleController>\(\))\.([a-z0-9_]+)(?!\()"),
      (match) {
        final prefix = match.group(1);
        final propName = match.group(2);
        if (propName == 'text' || propName == 'locale' || propName == 'values' || propName == 'copyWith') return match.group(0)!;
        return "$prefix.text('$propName')";
      }
    );

    // 5. Transform parameterized calls
    content = content.replaceAllMapped(
      RegExp(r"(l10n|innerL10n|context\.read<AppLocaleController>\(\)|context\.watch<AppLocaleController>\(\))\.([a-z0-9_]+)\(([^)]+)\)"),
      (match) {
        final prefix = match.group(1);
        final methodName = match.group(2);
        final args = match.group(3)!;
        
        if (methodName == 'text' || methodName == 'values' || methodName == 'copyWith') return match.group(0)!;

        // Custom mapping for known parameterized methods
        if (methodName == 'payment_amount_for') {
           return "$prefix.text('$methodName', {'name': $args})";
        }
        if (methodName == 'budget_title') {
           return "$prefix.text('$methodName', {'category': $args})";
        }
        if (methodName == 'complete_name_and_amount') {
           final splitArgs = args.split(',');
           if (splitArgs.length == 2) {
             return "$prefix.text('$methodName', {'name': ${splitArgs[0].trim()}, 'amount': ${splitArgs[1].trim()}})";
           }
        }
        
        return "$prefix.text('$methodName')";
      }
    );

    file.writeAsStringSync(content);
  }
  
  print('Robust refactor complete version 3');
}
