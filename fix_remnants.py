import re
import os

debt_file = 'lib/features/debts/screens/debt_screen.dart'
with open(debt_file, 'r', encoding='utf-8') as f:
    dl = f.read()

# Fix innerL10n
dl = re.sub(r'\binnerL10n\.([a-zA-Z0-9_]+)(?!\()', r"innerL10n.text('\1')", dl)

# Fix payment_amount_fo)r
dl = dl.replace("context.watch<AppLocaleController>().text('payment_amount_fo')r(debt.nombre)", "context.watch<AppLocaleController>().text('payment_amount_for', {'name': debt.nombre})")

with open(debt_file, 'w', encoding='utf-8') as f:
    f.write(dl)

trans_file = 'lib/core/i18n/app_translations.dart'
with open(trans_file, 'r', encoding='utf-8') as f:
    tl = f.read()

tl = tl.replace("'$imple'", r"'\$imple'")

with open(trans_file, 'w', encoding='utf-8') as f:
    f.write(tl)
print("done")
