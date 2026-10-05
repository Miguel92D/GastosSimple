import '../../features/transactions/models/transaction.dart';

/// Decide cómo restaurar cada fila de un backup sin pisar datos existentes.
///
/// Antes se usaba `ConflictAlgorithm.replace` por id: restaurar en un
/// teléfono que ya tenía movimientos sobrescribía en silencio las filas
/// con el mismo id. Ahora:
/// - id libre                  -> se inserta conservando el id (idempotente).
/// - id ocupado por la MISMA   -> se reemplaza (restaurar 2 veces no duplica).
///   entidad (mismos campos clave)
/// - id ocupado por OTRA cosa  -> se inserta como fila nueva (id nuevo).
///
/// Además [DatabaseHelper.restoreBackupData] saltea una fila si la misma
/// entidad ya está en el teléfono con OTRO id (por ejemplo, porque una
/// restauración anterior la insertó como nueva): así restaurar el mismo
/// archivo dos veces nunca duplica.
enum MergeAction { insertWithId, replace, insertAsNew, skip }

class BackupMerge {
  BackupMerge._();

  /// Campos que identifican "la misma entidad" por tabla.
  static const Map<String, List<String>> keyFields = {
    'transactions': ['amount', 'category', 'type', 'date'],
    'goals': ['name'],
    'debts': ['nombre'],
    // Sin 'amount': si el usuario actualizó el monto (ej. aumento del
    // alquiler) sigue siendo la misma recurrencia, no una nueva.
    'recurring_transactions': ['category', 'type', 'frequency'],
  };

  static MergeAction decide(
    Map<String, Object?>? existing,
    Map<String, Object?> incoming,
    List<String> keys, {
    String? table,
  }) {
    if (incoming['id'] == null) return MergeAction.insertAsNew;
    if (existing == null) return MergeAction.insertWithId;
    if (!sameEntity(existing, incoming, keys)) return MergeAction.insertAsNew;
    // Recurrencia que en este teléfono ya avanzó más que en el backup:
    // reemplazarla haría retroceder next_date y se volverían a generar
    // movimientos que ya existen (duplicados).
    if (table == 'recurring_transactions' && _isAhead(existing, incoming)) {
      return MergeAction.skip;
    }
    return MergeAction.replace;
  }

  /// true si [a] y [b] son la misma entidad según sus campos clave.
  static bool sameEntity(
    Map<String, Object?> a,
    Map<String, Object?> b,
    List<String> keys,
  ) {
    for (final k in keys) {
      if (!_same(k, a[k], b[k])) return false;
    }
    return true;
  }

  static bool _isAhead(
    Map<String, Object?> existing,
    Map<String, Object?> incoming,
  ) {
    final a = DateTime.tryParse(existing['next_date']?.toString() ?? '');
    final b = DateTime.tryParse(incoming['next_date']?.toString() ?? '');
    if (a == null || b == null) return false;
    return !a.isBefore(b);
  }

  static bool _same(String key, Object? a, Object? b) {
    if (a is num && b is num) return (a - b).abs() < 0.0001;
    // Filas viejas pueden tener el tipo escrito distinto ("Gasto") y el
    // backup lo trae normalizado ("gasto"): es el mismo movimiento.
    if (key == 'type') {
      return Transaction.normalizeType(a?.toString()) ==
          Transaction.normalizeType(b?.toString());
    }
    // Fechas guardadas con otro formato ("2026-09-01" y
    // "2026-09-01T00:00:00.000") son el mismo día.
    if (key == 'date' || key == 'next_date') {
      final da = DateTime.tryParse(a?.toString() ?? '');
      final db = DateTime.tryParse(b?.toString() ?? '');
      if (da != null && db != null) return da.isAtSameMomentAs(db);
    }
    return a?.toString() == b?.toString();
  }
}
