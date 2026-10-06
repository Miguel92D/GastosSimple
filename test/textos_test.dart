// Textos de la app (chat 09, D-034): las dos lenguas tienen las mismas claves
// y el español habla siempre de "tú" (respuesta a P-21).
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_translations.dart';

/// Formas de "vos" que no pueden volver (P-21). Van con tilde, porque sin
/// tilde varias son de "tú" ("anotas", "crea", "entra").
final _voseo = RegExp(
  r'(?<!\p{L})(vos|sos|podés|tenés|querés|permitís|definís|elegís|incluís|'
  r'vivís|cobrás|gastás|anotás|confirmás|aceptás|creás|entrá|intentá|abrí|'
  r'tocá|cargá|activá|esperá|mantené|creá|activalas|apagalo|guardalo)'
  r'(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

void main() {
  final es = AppTranslations.translations['es']!;
  final en = AppTranslations.translations['en']!;

  test('español e inglés tienen las mismas claves (D-008)', () {
    expect(es.keys.toSet().difference(en.keys.toSet()), isEmpty);
    expect(en.keys.toSet().difference(es.keys.toSet()), isEmpty);
  });

  test('el español usa "tú", no "vos" (P-21)', () {
    final found = <String>[];
    es.forEach((key, value) {
      for (final m in _voseo.allMatches(value)) {
        found.add('$key: ${m.group(0)}');
      }
    });
    expect(found, isEmpty);
  });
}
