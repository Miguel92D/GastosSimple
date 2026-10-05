import 'package:flutter/material.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Título de sección: MAYÚSCULAS, gris (`subLabel`), con el mismo aire en
/// todas las pantallas (D-032). `trailing` va a la derecha del texto (por
/// ejemplo, `ProBadge`).
class AppSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  /// Aire arriba del título. `false` cuando es lo primero de un bloque.
  final bool spaceAbove;

  const AppSectionTitle(
    this.text, {
    super.key,
    this.trailing,
    this.spaceAbove = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: spaceAbove ? AppSpacing.md : 0,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(text.toUpperCase(), style: AppTextStyles.subLabel),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
