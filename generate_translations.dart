import 'dart:io';
import 'dart:convert';

void main() async {
  final esFile = File('lib/l10n/app_es.arb');
  final enFile = File('lib/l10n/app_en.arb');

  final esData = jsonDecode(await esFile.readAsString());
  final enData = jsonDecode(await enFile.readAsString());

  final dir = Directory('lib/core/i18n');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final out = StringBuffer();
  out.writeln('class AppTranslations {');
  out.writeln('  static const Map<String, Map<String, String>> translations = {');

  void writeMap(String locale, Map<String, dynamic> data) {
    out.writeln("    '$locale': {");
    data.forEach((k, v) {
      if (!k.startsWith('@')) {
        final val = v.toString().replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n');
        out.writeln("      '$k': '$val',");
      }
    });
    out.writeln("    },");
  }

  writeMap('es', esData);
  writeMap('en', enData);

  out.writeln('  };');
  out.writeln('}');

  final outFile = File('lib/core/i18n/app_translations.dart');
  await outFile.writeAsString(out.toString());
  print('Generated lib/core/i18n/app_translations.dart');
}
