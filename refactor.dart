import 'dart:io';

void main() async {
  final file = File('lib/database/database_helper.dart');
  var content = await file.readAsString();

  if (!content.contains('exceptions.dart')) {
    content = content.replaceFirst(
        "import '../features/transactions/models/transaction.dart' as model;",
        "import '../features/transactions/models/transaction.dart' as model;\nimport '../core/error/exceptions.dart';");
  }

  // Regex to match catch blocks with debugPrint inside DatabaseHelper methods
  // Matches: catch (e) {
  //             debugPrint(...);
  //             return ...;
  //          }
  final regex = RegExp(r'catch\s*\((e|_)?\)\s*\{[^}]*debugPrint\((.*?)\);[^}]*\}', multiLine: true);

  content = content.replaceAllMapped(regex, (match) {
    final catchBlock = match.group(0)!;
    final methodMatch = RegExp(r'DB Error \((.*?)\)').firstMatch(catchBlock);
    
    if (methodMatch != null) {
      final methodName = methodMatch.group(1)!;
      if (methodName == 'close') return catchBlock;
      
      return '''catch (e, stackTrace) {
      debugPrint('DB Error ($methodName): \$e');
      throw DatabaseException('Operación fallida en $methodName', e);
    }''';
    }
    return catchBlock;
  });

  await file.writeAsString(content);
  print('Refactor applied.');
}
