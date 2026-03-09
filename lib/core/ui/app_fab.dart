import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../router/navigation_service.dart';
import 'quick_action_menu.dart';

class AppFAB extends StatelessWidget {
  final String mode; // "normal" o "vault"

  const AppFAB({super.key, this.mode = "normal"});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (mode == "normal") {
      return FloatingActionButton.extended(
        onPressed: () {
          NavigationService.navigate("/quick_entry");
        },
        label: Text(
          l10n.add_transaction_fab,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      );
    }

    return FloatingActionButton(
      onPressed: () {
        QuickActionMenu.open(context, mode: mode);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }
}
