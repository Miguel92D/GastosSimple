import 'dart:io';

void fixDirectory(Directory dir) {
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var newContent = content.replaceAll("text('tex')t(", "text(");
      newContent = newContent.replaceAll("AppLocalizations.of(context)!.not_set", "context.watch<AppLocaleController>().text('not_set')");
      if (content != newContent) {
        entity.writeAsStringSync(newContent);
      }
    }
  }
}

void main() {
  fixDirectory(Directory('lib'));
  print('done fix tex');
}
