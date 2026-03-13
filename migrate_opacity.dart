import 'dart:io';

void main() {
  final dir = Directory('lib');
  int count = 0;
  
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      // Replace Color.withOpacity(...) with Color.withValues(alpha: ...)
      // We must be careful that it is only applied where .withOpacity( ) is used.
      final newContent = content.replaceAllMapped(
        RegExp(r'\.withOpacity\((.*?)\)'),
        (match) => '.withValues(alpha: ${match.group(1)})',
      );
      
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        count++;
      }
    }
  }
  print('Updated \$count files.');
}
