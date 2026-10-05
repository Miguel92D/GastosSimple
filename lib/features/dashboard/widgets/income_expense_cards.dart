import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';

class IncomeExpenseCards extends StatelessWidget {
  final double income;
  final double expenses;
  final String? selectedFilter;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const IncomeExpenseCards({
    super.key,
    required this.income,
    required this.expenses,
    this.selectedFilter,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final l10n = context.watch<AppLocaleController>();
        final hidden = AppState.instance.hideBalance;
        final incomeText = hidden
            ? '••••••'
            : CurrencyHelper.format(income, context);
        final expenseText = hidden
            ? '••••••'
            : CurrencyHelper.format(expenses, context);
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Las dos tarjetas usan el MISMO tamaño de monto: el que hace
              // entrar al más largo. Así quedan del mismo alto y se ven iguales.
              final cardWidth = (constraints.maxWidth - AppSpacing.md) / 2;
              final amountSize = _StatCard.amountSizeFor(context, [
                incomeText,
                expenseText,
              ], cardWidth);
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l10n.text('income'),
                      amountText: incomeText,
                      amountSize: amountSize,
                      color: AppColors.incomeGreen,
                      isSelected: selectedFilter == 'ingreso',
                      onTap: onIncomeTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: l10n.text('expense'),
                      amountText: expenseText,
                      amountSize: amountSize,
                      color: AppColors.expenseRed,
                      isSelected: selectedFilter == 'gasto',
                      onTap: onExpenseTap,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String amountText;
  final double amountSize;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.amountText,
    required this.amountSize,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  static const double _padding = AppSpacing.md;
  static const double _maxAmountSize = 20;

  static TextStyle _amountStyle(double size) =>
      AppTextStyles.incomeValue.copyWith(fontSize: size);

  /// Tamaño de letra que hace entrar todos los [texts] en una tarjeta de
  /// [cardWidth] (como mucho 20).
  static double amountSizeFor(
    BuildContext context,
    List<String> texts,
    double cardWidth,
  ) {
    // Ancho útil: padding a los dos lados, borde y un margen chico.
    final available = cardWidth - 2 * _padding - 4;
    if (available <= 0) return _maxAmountSize;
    final scaler = MediaQuery.textScalerOf(context);
    var widest = 0.0;
    for (final text in texts) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _amountStyle(_maxAmountSize)),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    if (widest <= available) return _maxAmountSize;
    return _maxAmountSize * available / widest;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GlassCard(
          glowColor: isSelected
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.08),
          padding: const EdgeInsets.all(_padding),
          borderRadius: AppRadius.lg,
          // Mismo ancho de borde en los dos estados: la tarjeta no cambia de
          // alto al seleccionarla.
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? color.withValues(alpha: 0.8)
                      : AppColors.softText.withValues(alpha: 0.65),
                  // Mismo peso en ambos estados: el texto no "salta" al seleccionar.
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Por las dudas sigue el FittedBox: nunca se corta el monto.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amountText,
                  style: _amountStyle(amountSize).copyWith(color: color),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
