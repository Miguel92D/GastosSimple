import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/ui/category_icons.dart';

void main() {
  group('CategoryIcons (P-10)', () {
    test('las categorías de "Agregar movimiento" tienen su propio ícono', () {
      const categorias = [
        'Comida',
        'Transporte',
        'Salud',
        'Ocio',
        'Compras',
        'Suscripciones',
        'Servicios',
        'Tarjeta de Crédito',
        'Préstamos',
        'Regalos',
        'Otros',
        'Salario',
        'Inversiones',
        'Ventas',
        'Bonos',
      ];
      for (final c in categorias) {
        expect(CategoryIcons.of(c), isNot(CategoryIcons.fallback), reason: c);
      }
    });

    test('el mismo ícono sin importar cómo quedó guardado el nombre', () {
      expect(CategoryIcons.of('Regalo'), CategoryIcons.of('Regalos'));
      expect(CategoryIcons.of('cat_gift'), CategoryIcons.of('Regalos'));
      expect(CategoryIcons.of('Venta'), CategoryIcons.of('Ventas'));
      expect(CategoryIcons.of('Inversión'), CategoryIcons.of('Inversiones'));
      expect(CategoryIcons.of('tarjeta de credito'), Icons.credit_card_rounded);
      expect(CategoryIcons.of(' Préstamos '), Icons.handshake_rounded);
      expect(CategoryIcons.of('Shopping'), Icons.shopping_bag_rounded);
    });

    test('una categoría escrita por el usuario usa el ícono genérico', () {
      expect(CategoryIcons.of('Mascotas'), CategoryIcons.fallback);
    });

    test('ninguna pantalla arma su propio mapa de íconos', () {
      final offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where(
            (f) => !f.path
                .replaceAll('\\', '/')
                .endsWith('core/ui/category_icons.dart'),
          )
          .where((f) {
            final s = f.readAsStringSync();
            return s.contains('_categoryIcons') ||
                s.contains('_getCategoryIcon') ||
                s.contains("case 'cat_food'") && s.contains('Icons.');
          })
          .map((f) => f.path);
      expect(offenders, isEmpty);
    });
  });
}
