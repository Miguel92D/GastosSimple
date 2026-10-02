/// Decide cómo restaurar cada fila de un backup sin pisar datos existentes.
///
/// Antes se usaba `ConflictAlgorithm.replace` por id: restaurar en un
/// teléfono que ya tenía movimientos sobrescribía en silencio las filas
/// con el mismo id. Ahora:
/// - id libre                  -> se inserta conservando el id (idempotente).
/// - id ocupado por la MISMA   -> se reemplaza (restaurar 2 veces no duplica).
///   entidad (mismos campos clave)
/// - id ocupado por OTRA cosa  -> se inserta como fila nueva (id nuevo).
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
    for (final k in keys) {
      if (!_same(existing[k], incoming[k])) return MergeAction.insertAsNew;
    }
    // Recurrencia que en este teléfono ya avanzó más que en el backup:
    // reemplazarla haría retroceder next_date y se volverían a generar
    // movimientos que ya existen (duplicados).
    if (table == 'recurring_transactions' && _isAhead(existing, incoming)) {
      return MergeAction.skip;
    }
    return MergeAction.replace;
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

  static bool _same(Object? a, Object? b) {
    if (a is num && b is num) return (a - b).abs() < 0.0001;
    return a?.toString() == b?.toString();
  }
}
