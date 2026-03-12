import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Replace imports
    # Looking for: import 'package:gastos_simple/l10n/app_localizations.dart';
    # Or import '../../l10n/app_localizations.dart';
    if 'AppLocalizations' in content:
        content = re.sub(r'import .*/l10n/app_localizations\.dart[^;]*;', 
                         "import 'package:provider/provider.dart';\nimport 'package:gastos_simple/core/i18n/app_locale_controller.dart';", content)
        # Also clean up flutter_gen/gen_l10n/app_localizations if any
        content = re.sub(r'import .flutter_gen/gen_l10n/app_localizations\.dart[^;]*;', '', content)

    # 1. Properties
    content = re.sub(r'AppLocalizations\.of\(context\)!\.([a-zA-Z0-9_]+)(?!\()', r"context.watch<AppLocaleController>().text('\1')", content)

    # 2. Methods with 1 argument
    methods_1_arg = {
        'days_count': 'count',
        'closing_day': 'day',
        'snowball_method': 'name',
        'interest_annual': 'rate',
        'remaining_amount': 'amount',
        'min_pay_amount': 'amount',
        'budget_title': 'category',
        'top_category_insight': 'category',
        'payment_amount_for': 'name'
    }
    for m, arg in methods_1_arg.items():
        pattern = r'AppLocalizations\.of\(context\)!\.' + m + r'\(([^)]+)\)'
        repl = r"context.watch<AppLocaleController>().text('" + m + r"', {'" + arg + r"': \1})"
        content = re.sub(pattern, repl, content)

    # 3. Methods with 2 arguments
    methods_2_args = {
        'priority_tip': ['name', 'rate']
    }
    for m, args in methods_2_args.items():
        # Match two arguments separated by comma
        pattern = r'AppLocalizations\.of\(context\)!\.' + m + r'\(([^,]+),\s*([^)]+)\)'
        repl = r"context.watch<AppLocaleController>().text('" + m + r"', {'" + args[0] + r"': \1, '" + args[1] + r"': \2})"
        content = re.sub(pattern, repl, content)

    # 4. extra_payment_tip with 3 arguments
    pattern = r'AppLocalizations\.of\(context\)!\.extra_payment_tip\(([^,]+),\s*([^,]+),\s*([^)]+)\)'
    repl = r"context.watch<AppLocaleController>().text('extra_payment_tip', {'amount': \1, 'name': \2, 'months': \3})"
    content = re.sub(pattern, repl, content)

    if content != original_content:
        # If the file didn't import provider previously, the regex substituted it. BUT if the file didn't have the import to begin with?
        # Let's ensure 'package:provider/provider.dart' is imported if 'context.watch<AppLocaleController>' is used
        if 'context.watch<AppLocaleController>' in content and 'package:provider/provider.dart' not in content:
            content = "import 'package:provider/provider.dart';\n" + content
        if 'context.watch<AppLocaleController>' in content and 'package:gastos_simple/core/i18n/app_locale_controller.dart' not in content:
            content = "import 'package:gastos_simple/core/i18n/app_locale_controller.dart';\n" + content

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")


def walk_dir(directory):
    for root, dirs, files in os.walk(directory):
        if 'l10n' in root or 'i18n' in root:
            continue
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == '__main__':
    walk_dir('lib')

