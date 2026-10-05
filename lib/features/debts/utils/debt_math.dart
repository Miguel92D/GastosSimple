import '../../../core/utils/money.dart';
import '../models/debt.dart';

/// Cuentas de la pantalla de Deudas, sin UI (testeables).
class DebtMath {
  DebtMath._();

  static const String avalanche = 'avalanche';
  static const String snowball = 'snowball';

  /// Lo que falta pagar entre todas las deudas, en centavos (D-005).
  /// Una deuda pagada de más cuenta 0: no "descuenta" de las otras.
  static double totalRemaining(Iterable<Debt> debts) =>
      Money.sum(debts.map((d) => d.isPaid ? 0.0 : d.remaining));

  /// Ordena según la estrategia. Las saldadas van siempre al final, para
  /// que la primera de la lista sea la que conviene pagar.
  /// - Avalancha: mayor tasa de interés primero.
  /// - Bola de nieve: menor saldo pendiente primero.
  /// Con otra estrategia se deja el orden original.
  static List<Debt> sortForStrategy(List<Debt> debts, String strategy) {
    final int Function(Debt a, Debt b) byStrategy;
    if (strategy == avalanche) {
      byStrategy = (a, b) => (b.tasaInteres ?? 0).compareTo(a.tasaInteres ?? 0);
    } else if (strategy == snowball) {
      byStrategy = (a, b) =>
          Money.toCents(a.remaining).compareTo(Money.toCents(b.remaining));
    } else {
      return List.of(debts);
    }
    final unpaid = debts.where((d) => !d.isPaid).toList()..sort(byStrategy);
    final paid = debts.where((d) => d.isPaid);
    return [...unpaid, ...paid];
  }

  /// La deuda a atacar primero (la primera sin saldar), o null.
  static Debt? priority(List<Debt> sorted) {
    for (final d in sorted) {
      if (!d.isPaid) return d;
    }
    return null;
  }
}
