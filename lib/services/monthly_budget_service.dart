import 'package:shared_preferences/shared_preferences.dart';

/// Presupuesto mensual total de gasto (opcional). Si está definido, "Podés
/// gastar hoy" lo usa como base en lugar de los ingresos del mes.
class MonthlyBudgetService {
  MonthlyBudgetService._();

  static const _key = 'monthly_spending_budget';

  static Future<double?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_key);
    return (value == null || value <= 0) ? null : value;
  }

  /// null o <= 0 lo quita.
  static Future<void> set(double? amount) async {
    final prefs = await SharedPreferences.getInstance();
    if (amount == null || amount <= 0) {
      await prefs.remove(_key);
    } else {
      await prefs.setDouble(_key, amount);
    }
  }
}
