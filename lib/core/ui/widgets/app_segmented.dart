import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_icons.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Una opción de `AppSegmented`.
class AppSegment<T> {
  final T value;
  final String label;
  final IconData? icon;

  /// Color de fondo cuando está elegida (por defecto violeta).
  final Color color;

  const AppSegment({
    required this.value,
    required this.label,
    this.icon,
    this.color = AppColors.primaryPurple,
  });
}

/// Selector de dos o más opciones (Día/Mes, Ingreso/Gasto). Opciones 20×10,
/// radio `sm`, letra 13/w800 en MAYÚSCULAS; el peso no cambia al elegir.
class AppSegmented<T> extends StatelessWidget {
  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Las opciones se reparten todo el ancho.
  final bool expand;

  const AppSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) children.add(const SizedBox(width: AppSpacing.xs));
      final option = _Option<T>(
        segment: segments[i],
        isSelected: segments[i].value == selected,
        onTap: () => onChanged(segments[i].value),
      );
      children.add(expand ? Expanded(child: option) : option);
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _Option<T> extends StatelessWidget {
  final AppSegment<T> segment;
  final bool isSelected;
  final VoidCallback onTap;

  const _Option({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isSelected
        ? AppColors.textPrimary
        : AppColors.softText.withValues(alpha: 0.6);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? segment.color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (segment.icon != null) ...[
              Icon(segment.icon, size: AppIconSize.small, color: fg),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                segment.label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.segmentLabel.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
