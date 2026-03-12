import 'dart:io';

void main() {
  final f = File('lib/features/debts/screens/debt_screen.dart');
  var content = f.readAsStringSync();
  
  content = content.replaceAll("text('tex')t(", "text(");
  content = content.replaceAll("innerL10n.complete_name_and_amount(debt.nombre, CurrencyHelper.format(debt.montoTotal, context))", "innerL10n.text('complete_name_and_amount', {'name': debt.nombre, 'amount': CurrencyHelper.format(debt.montoTotal, context)})");
  content = content.replaceAll("innerL10n.payment_amount_for(widget.debt.nombre)", "innerL10n.text('payment_amount_for', {'name': widget.debt.nombre})");
  content = content.replaceAll("innerL10n.payment_amount_for(debt.nombre)", "innerL10n.text('payment_amount_for', {'name': debt.nombre})");
  content = content.replaceAll("innerL10n.payment_amount_hint", "innerL10n.text('payment_amount_hint')");
  content = content.replaceAll("innerL10n.confirm_payment", "innerL10n.text('confirm_payment')");
  content = content.replaceAll("innerL10n.paid_label", "innerL10n.text('paid_label')");
  
  f.writeAsStringSync(content);
  print('done debt');
}
