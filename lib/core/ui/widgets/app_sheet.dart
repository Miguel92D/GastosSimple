import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Panel de abajo. Siempre igual (D-032): fondo `darkBackground`, radio
/// `xl` arriba, rayita para arrastrar, fondo oscurecido al 75% y sube con
/// el teclado.
///
/// ```dart
/// final r = await AppSheet.show<String>(context, builder: (ctx) => ...);
/// ```
class AppSheet {
  AppSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,

    /// Alto máximo como parte de la pantalla.
    double maxHeightFactor = 0.9,

    /// Margen a los costados del contenido. Las listas de opciones hechas
    /// con `ListTile` usan 0 (el `ListTile` ya trae su margen).
    double horizontalPadding = AppSpacing.screen,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBackground,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * maxHeightFactor,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSheetHandle(),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      AppSpacing.lg,
                    ),
                    child: Builder(builder: builder),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Una opción dentro de un panel: ícono de color y texto.
class AppSheetOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  /// Texto en el color del ícono (por ejemplo, rojo para "Dejar de repetir").
  final bool tintLabel;

  const AppSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primaryPurple,
    this.tintLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: tintLabel
            ? AppTextStyles.bodyMain.copyWith(color: color)
            : AppTextStyles.bodyMain,
      ),
      onTap: onTap,
    );
  }
}

/// Título de un panel (18, centrado).
class AppSheetTitle extends StatelessWidget {
  final String text;

  const AppSheetTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.titleSmall,
      ),
    );
  }
}

/// La rayita de arriba de un panel. Solo la usa `AppSheet`.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.md,
        ),
        width: 40,
        height: AppRadius.bar,
        decoration: BoxDecoration(
          color: AppColors.cardBorder,
          borderRadius: BorderRadius.circular(AppRadius.bar / 2),
        ),
      ),
    );
  }
}
