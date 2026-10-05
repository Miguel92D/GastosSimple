import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

/// "Ver mi compra en Google Play" (D-027). PRO es un pago único: no hay
/// suscripción que cancelar; desde el historial de pedidos de Google Play se
/// ve la compra y se pide un reembolso. Solo se muestra con PRO.
class ManagePurchaseButton extends StatelessWidget {
  const ManagePurchaseButton({super.key});

  static final Uri orderHistoryUri = Uri.parse(
    'https://play.google.com/store/account/orderhistory',
  );

  /// Abre el enlace afuera de la app (en Play Store). Se cambia en los tests.
  @visibleForTesting
  static Future<bool> Function(Uri uri) opener = (uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  Future<void> _open(BuildContext context) async {
    final l10n = context.read<AppLocaleController>();
    final messenger = ScaffoldMessenger.of(context);
    bool opened;
    try {
      opened = await opener(orderHistoryUri);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.text('premium_manage_open_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(
            AppIcons.pro,
            color: AppColors.primaryPurple,
          ),
          title: Text(
            l10n.text('premium_manage_purchase'),
            style: AppTextStyles.bodyMain.copyWith(fontWeight: FontWeight.w600),
          ),
          trailing: Icon(
            AppIcons.openOutside,
            color: AppColors.softText.withAlpha(120),
          ),
          onTap: () => _open(context),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            l10n.text('premium_google_play_manage_note'),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.softText.withAlpha(165),
            ),
          ),
        ),
      ],
    );
  }
}
