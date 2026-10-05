import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../utils/currency_helper.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Un monto con su tamaño fijo según dónde va (R-4, D-030). Lo formatea
/// con la moneda elegida y lo tapa con `••••••` si el saldo está oculto.
///
/// Hoy tiene una variante: [AppAmount.list] (15, dentro de una fila). El
/// balance y las tarjetas de Ingresos/Gastos ya tienen su módulo
/// (`BalanceCard`, `IncomeExpenseCards`).
class AppAmount extends StatelessWidget {
  static const String hiddenText = '••••••';

  final double value;
  final Color color;

  /// Signo delante del monto (`+` o `-`), si la fila lo muestra.
  final String prefix;

  /// Texto en lugar del monto (por ejemplo, "Pagada").
  final String? label;

  /// Fuerza ocultar o mostrar. Si es `null`, sigue al ojo del inicio.
  final bool? hidden;

  final TextStyle _style;

  const AppAmount.list({
    super.key,
    required this.value,
    this.color = AppColors.textPrimary,
    this.prefix = '',
    this.label,
    this.hidden,
  }) : _style = AppTextStyles.amountList;

  @override
  Widget build(BuildContext context) {
    final isHidden = hidden ?? context.watch<AppState>().hideBalance;
    final text =
        label ??
        (isHidden
            ? hiddenText
            : '$prefix${CurrencyHelper.format(value, context)}');
    // Se achica antes que cortarse con "…".
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(text, maxLines: 1, style: _style.copyWith(color: color)),
    );
  }
}
