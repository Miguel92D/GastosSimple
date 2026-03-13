import 'dart:io';

void main() {
  final file = File('lib/database/database_helper.dart');
  String content = file.readAsStringSync();
  
  // Replace (e, stackTrace) with (e, _) if stackTrace is unused.
  // Actually, I can just replace all (e, stackTrace) with (e, _) to be safe since I'm not using them except for logging which I removed from some places.
  // Wait, I should use (e, _) if I just want to suppress the warning.
  
  content = content.replaceAll("(e, stackTrace)", "(e, _) ");
  
  file.writeAsStringSync(content);
  print('Suppressed unused stack trace warnings');
}
