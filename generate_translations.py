import os
import json
import re

def main():
    with open('lib/l10n/app_es.arb', 'r', encoding='utf-8') as f:
        es_data = json.load(f)
    with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
        en_data = json.load(f)
        
    os.makedirs('lib/core/i18n', exist_ok=True)
    
    with open('lib/core/i18n/app_translations.dart', 'w', encoding='utf-8') as f:
        f.write('class AppTranslations {\n')
        f.write('  static const Map<String, Map<String, String>> translations = {\n')
        
        # Spanish
        f.write("    'es': {\n")
        for k, v in es_data.items():
            if k.startswith('@'): continue
            val = v.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")
            f.write(f"      '{k}': '{val}',\n")
        f.write("    },\n")

        # English
        f.write("    'en': {\n")
        for k, v in en_data.items():
            if k.startswith('@'): continue
            val = v.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")
            f.write(f"      '{k}': '{val}',\n")
        f.write("    },\n")

        f.write('  };\n')
        f.write('}\n')

if __name__ == '__main__':
    main()
