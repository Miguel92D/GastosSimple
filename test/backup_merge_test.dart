import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/backup_merge.dart';

void main() {
  final keys = BackupMerge.keyFields['transactions']!;
  final row = {
    'id': 7,
    'amount': 1530.0,
    'category': 'Comida',
    'type': 'gasto',
    'date': '2026-09-01T10:00:00.000',
  };

  test('id libre: se inserta conservando el id', () {
    expect(BackupMerge.decide(null, row, keys), MergeAction.insertWithId);
  });

  test('mismo movimiento: se reemplaza (restaurar 2 veces no duplica)', () {
    expect(
      BackupMerge.decide({...row, 'amount': 1530}, row, keys),
      MergeAction.replace,
    );
  });

  test('id ocupado por OTRO movimiento: se inserta como nuevo, sin pisar', () {
    final otro = {...row, 'category': 'Transporte', 'amount': 900.0};
    expect(BackupMerge.decide(otro, row, keys), MergeAction.insertAsNew);
  });

  group('recurrencias', () {
    final rk = BackupMerge.keyFields['recurring_transactions']!;
    final backup = {
      'id': 3,
      'amount': 300000.0,
      'category': 'Servicios',
      'type': 'gasto',
      'frequency': 'monthly',
      'next_date': '2026-11-01T00:00:00.000',
    };

    test('no retrocede una recurrencia que ya avanzó (evita duplicados)', () {
      final local = {...backup, 'next_date': '2027-01-01T00:00:00.000'};
      expect(
        BackupMerge.decide(local, backup, rk, table: 'recurring_transactions'),
        MergeAction.skip,
      );
    });

    test('monto actualizado sigue siendo la misma recurrencia', () {
      final local = {
        ...backup,
        'amount': 350000.0,
        'next_date': '2026-10-01T00:00:00.000',
      };
      expect(
        BackupMerge.decide(local, backup, rk, table: 'recurring_transactions'),
        MergeAction.replace,
      );
    });
  });

  test('fila sin id: siempre nueva', () {
    expect(
      BackupMerge.decide(null, {...row, 'id': null}, keys),
      MergeAction.insertAsNew,
    );
  });
}
