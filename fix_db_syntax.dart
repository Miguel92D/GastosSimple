import 'dart:io';

void main() {
  final file = File('lib/database/database_helper.dart');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }
  
  String content = file.readAsStringSync();
  
  // 1. Fix ambiguous import
  content = content.replaceFirst(
    "import 'package:sqflite/sqflite.dart';",
    "import 'package:sqflite/sqflite.dart' hide DatabaseException;"
  );
  
  // 2. Fix stray syntax in getExpensesByCategory
  // Old:
  // throw DatabaseException('Operación fallida en getExpensesByCategory', e);
  //     };
  //     }
  //   }
  
  content = content.replaceFirst(
    "throw DatabaseException('Operación fallida en getExpensesByCategory', e);\n      };\n      }\n    }",
    "throw DatabaseException('Operación fallida en getExpensesByCategory', e);\n    }"
  );
  
  // 3. Fix static access in close()
  content = content.replaceFirst(
    "final db = await instance.database;",
    "final db = await DatabaseHelper.instance.database;"
  );

  // 4. Fix potential stray semicolons after catch blocks if they exist
  content = content.replaceAll("};", "}");
  
  // Wait, let's be careful with the brace count.
  // The error analysis said:
  // error - Undefined name 'instance' - lib\database\database_helper.dart:797:24 - undefined_identifier
  // error - Expected a method, getter, setter or operator declaration - lib\database\database_helper.dart:803:1 - expected_executable
  
  file.writeAsStringSync(content);
  print('Fixed database_helper.dart');
}
