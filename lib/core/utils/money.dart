/// Aritmética de dinero sin errores de punto flotante.
///
/// Los montos se siguen guardando como REAL (no se migró la base a
/// centavos enteros, ver PROYECTO_REGLAS.md), pero:
/// - toda escritura se redondea a centavos ([round]),
/// - toda suma se hace en centavos enteros ([sum]),
/// - las comparaciones contra cero usan tolerancia ([isZero]).
/// Así 0,1 + 0,2 da 0,30 y una deuda saldada da 0 restante, no 1e-9.
class Money {
  Money._();

  static int toCents(double value) => (value * 100).round();

  static double fromCents(int cents) => cents / 100;

  /// Redondea a 2 decimales (centavos).
  static double round(double value) => fromCents(toCents(value));

  /// Suma exacta en centavos.
  static double sum(Iterable<double> values) =>
      fromCents(values.fold<int>(0, (acc, v) => acc + toCents(v)));

  /// true si el monto es cero a nivel de centavos.
  static bool isZero(double value) => toCents(value) == 0;
}
