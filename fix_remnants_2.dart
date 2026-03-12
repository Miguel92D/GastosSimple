import 'dart:io';

void main() {
  final budgetFile = File('lib/features/budgets/screens/budget_screen.dart');
  var bl = budgetFile.readAsStringSync();
  
  bl = bl.replaceAll('''            AppLocalizations.of(
              context,
            )!.budget_title(L10nHelper.getLocalizedCategory(context, category)),''', '''            context.watch<AppLocaleController>().text('budget_title', {'category': L10nHelper.getLocalizedCategory(context, category)}),''');

  bl = bl.replaceAll('''                                            AppLocalizations.of(
                                              context,
                                            )!.not_set,''', '''                                            context.watch<AppLocaleController>().text('not_set'),''');

  budgetFile.writeAsStringSync(bl);

  final helperFile = File('lib/core/utils/l10n_helper.dart');
  var hl = helperFile.readAsStringSync();
  
  hl = hl.replaceFirst("import '../../l10n/app_localizations.dart';", "import '../i18n/app_locale_controller.dart';\nimport 'package:provider/provider.dart';");
  hl = hl.replaceFirst("final l10n = AppLocalizations.of(context);", "final l10n = context.read<AppLocaleController>();");
  
  hl = hl.replaceAllMapped(RegExp(r'return l10n\.(cat_[a-z_]+);'), (m) {
    return "return l10n.text('${m[1]}');";
  });

  helperFile.writeAsStringSync(hl);
  
  print("done2");
}
