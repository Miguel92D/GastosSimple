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
    
    // 3. Fix direct uses in build
    content = content.replaceAll(
      "AppLocalizations.of(context)!",
      "context.read<AppLocaleController>()"
    );

    // 4. Batch replace property access with .text() calls
    content = content.replaceAllMapped(
      RegExp(r"(l10n|innerL10n)\.([a-z0-9_]+)(?!\()"),
      (match) {
        final varName = match.group(1);
        final propName = match.group(2);
        if (propName == 'text' || propName == 'locale' || propName == 'values' || propName == 'copyWith') return match.group(0)!;
        return "$varName.text('$propName')";
      }
    );

    // 5. Handle parameterized calls
    content = content.replaceAllMapped(
      RegExp(r"(l10n|innerL10n)\.([a-z0-9_]+)\(([^)]+)\)"),
      (match) {
        final varName = match.group(1);
        final methodName = match.group(2);
        final args = match.group(3)!;
        
        if (methodName == 'text' || methodName == 'values' || methodName == 'copyWith') return match.group(0)!;

        // Custom mapping for known parameterized methods
        if (methodName == 'payment_amount_for') {
           return "$varName.text('$methodName', {'name': $args})";
        }
        if (methodName == 'budget_title') {
           return "$varName.text('$methodName', {'category': $args})";
        }
        if (methodName == 'complete_name_and_amount') {
           final splitArgs = args.split(',');
           if (splitArgs.length == 2) {
             return "$varName.text('$methodName', {'name': ${splitArgs[0].trim()}, 'amount': ${splitArgs[1].trim()}})";
           }
        }
        
        return "$varName.text('$methodName')";
      }
    );

    file.writeAsStringSync(content);
  }
  
  print('Robust refactor complete');
}
