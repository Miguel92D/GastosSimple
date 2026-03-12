import 'dart:io';

void main() {
  final debtFile = File('lib/features/debts/screens/debt_screen.dart');
  var dl = debtFile.readAsStringSync();

  // Fix innerL10n
  dl = dl.replaceAllMapped(RegExp(r'\binnerL10n\.([a-zA-Z0-9_]+)(?!\()'), (m) {
    if (m[1] == 'text') return m[0]!;
    return "innerL10n.text('${m[1]}')";
  });

  // Fix payment_amount_fo)r
  dl = dl.replaceAll(
      "context.watch<AppLocaleController>().text('payment_amount_fo')r(debt.nombre)",
      "context.watch<AppLocaleController>().text('payment_amount_for', {'name': debt.nombre})");

  debtFile.writeAsStringSync(dl);

  final transFile = File('lib/core/i18n/app_translations.dart');
  var tl = transFile.readAsStringSync();

  tl = tl.replaceAll(r"'\$imple'", r"'\$imple'");
  tl = tl.replaceAll(r'"\$imple"', r'"\$imple"');
  // It was parsed from JSON so it's probably '\$imple' string literal missing the backslash, or `"\$imple"`.
  tl = tl.replaceAll(r"'$imple'", r"'\$imple'");
  tl = tl.replaceAll(r'"$imple"', r'"\$imple"');

  transFile.writeAsStringSync(tl);
  print("done");
}
