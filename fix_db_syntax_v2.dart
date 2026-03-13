import 'dart:io';

void main() {
  final file = File('lib/database/database_helper.dart');
  List<String> lines = file.readAsLinesSync();
  
  // Fix imports (line 2 usually)
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("import 'package:sqflite/sqflite.dart';")) {
      lines[i] = "import 'package:sqflite/sqflite.dart' hide DatabaseException;";
    }
    
    // Fix missing semicolon at line 781 (index 780 if 0-based, but let's be more robust)
    if (lines[i].contains("Map<String, double> data = {}") && !lines[i].contains(";")) {
      lines[i] = lines[i].replaceFirst("{}", "{};");
    }

    // Fix static access at line 797
    if (lines[i].contains("final db = await instance.database;")) {
       lines[i] = lines[i].replaceFirst("instance.database", "DatabaseHelper.instance.database");
    }
    
    // Fix static access in all other methods if needed (let's check a few)
    if (lines[i].contains("final db = await instance.database;")) {
       lines[i] = lines[i].replaceFirst("instance.database", "DatabaseHelper.instance.database");
    }
  }

  // Remove the stray brace after line 792
  // Let's find the getExpensesByCategory method and fix its ending.
  // We can join lines and use a more global replace for that specific method if it's broken.
  
  String content = lines.join("\n");
  
  // Fix the stray brace in getExpensesByCategory
  // Pattern: 
  //     } catch (e, stackTrace) {
  //       debugPrint('DB Error (getExpensesByCategory): $e');
  //       throw DatabaseException('Operación fallida en getExpensesByCategory', e);
  //     }
  //     }
  //   }
  
  content = content.replaceFirst(
    "throw DatabaseException('Operación fallida en getExpensesByCategory', e);\n    }\n    }\n  }",
    "throw DatabaseException('Operación fallida en getExpensesByCategory', e);\n    }\n  }"
  );

  // Global fix for instance access
  content = content.replaceAll("await instance.database", "await DatabaseHelper.instance.database");

  file.writeAsStringSync(content);
  print('Fixed database_helper.dart with more care');
}
