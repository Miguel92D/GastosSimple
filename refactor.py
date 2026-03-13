import re

file_path = 'lib/database/database_helper.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add import if missing
    if 'exceptions.dart' not in content:
        content = content.replace("import '../features/transactions/models/transaction.dart' as model;", "import '../features/transactions/models/transaction.dart' as model;\nimport '../core/error/exceptions.dart';")

    def replacer(match):
        catch_block = match.group(0)
        method_name = re.search(r"DB Error \((.*?)\)", catch_block)
        if method_name:
            b = method_name.group(1)
            # if the method is close, ignore it or allow it
            if b == 'close':
                return catch_block
        else:
            b = 'Unknown'
        
        replacement = f"""catch (e, stackTrace) {{
      debugPrint('DB Error ({b}): $e');
      throw DatabaseException('Operación fallida en {b}', e);
    }}"""
        return replacement

    pattern = r'catch\s*\((e|_)?\)\s*\{[^}]*debugPrint\((.*?)\);[^}]*\}'
    content = re.sub(pattern, replacer, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Database helper refactored successfully.")
except Exception as e:
    print(f"Error: {e}")
