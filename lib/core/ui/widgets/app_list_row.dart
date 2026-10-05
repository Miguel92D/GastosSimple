import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../glass_card.dart';
import 'app_icon_box.dart';

/// Fila de lista (D-032): caja de ícono 40, título 14 negrita, subtítulo 12
/// gris y, a la derecha, el monto (`AppAmount.list`) u otra cosa.
///
/// - Movimientos, Pagos fijos y Deudas: `AppListRow(...)` (va en su tarjeta).
/// - Deudas: `framed: false` dentro de su propia tarjeta, con barra y botones.
/// - Ajustes: `AppListRow.setting(...)`, caja violeta, sin monto, con `›`.
class AppListRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBoxColor;
  final String title;

  /// Algo chico al lado del título (por ejemplo, "PRIORIDAD").
  final Widget? titleTrailing;
  final String? subtitle;

  /// Más renglones debajo del subtítulo.
  final List<Widget> extra;

  /// Lo de la derecha: casi siempre un `AppAmount.list`.
  final Widget? trailing;

  /// Texto chico debajo de lo de la derecha (nota, porcentaje).
  final Widget? trailingCaption;
  final VoidCallback? onTap;

  /// Con su tarjeta de vidrio (radio `lg`). `false` si ya está dentro de una.
  final bool framed;

  /// Muestra `›` a la derecha cuando no hay [trailing] (Ajustes).
  final bool _chevron;

  const AppListRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.iconBoxColor,
    this.titleTrailing,
    this.subtitle,
    this.extra = const [],
    this.trailing,
    this.trailingCaption,
    this.onTap,
    this.framed = true,
  }) : _chevron = false;

  /// Fila de Ajustes: caja violeta, sin monto; a la derecha `›` o [trailing].
  const AppListRow.setting({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : iconColor = AppColors.primaryPurple,
       iconBoxColor = null,
       titleTrailing = null,
       extra = const [],
       trailingCaption = null,
       framed = false,
       _chevron = true;

  @override
  Widget build(BuildContext context) {
    final row = LayoutBuilder(
      builder: (context, constraints) => _content(constraints.maxWidth),
    );

    if (!framed) {
      if (onTap == null) return row;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: row,
        ),
      );
    }

    final card = GlassCard(
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      child: row,
    );
    return onTap == null
        ? card
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: card,
          );
  }

  Widget _content(double maxWidth) {
    return Row(
      children: [
        AppIconBox(icon: icon, color: iconColor, boxColor: iconBoxColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.rowTitle,
                    ),
                  ),
                  if (titleTrailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    titleTrailing!,
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  // Un renglón: la fila mide siempre lo mismo (R-4).
                  maxLines: _chevron ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowSubtitle,
                ),
              ],
              ...extra,
            ],
          ),
        ),
        if (trailing != null || _chevron) ...[
          const SizedBox(width: AppSpacing.sm),
          // Lo de la derecha usa a lo sumo el 45% de la fila; un monto
          // gigante se achica (AppAmount) en vez de empujar el título.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth * 0.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                trailing ??
                    Icon(
                      AppIcons.next,
                      color: AppColors.softText.withValues(alpha: 0.3),
                    ),
                if (trailingCaption != null) ...[
                  const SizedBox(height: 2),
                  trailingCaption!,
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
