import 'package:flutter/material.dart';
import '../../features/analysis/screens/monthly_analysis_screen.dart';

import '../../features/dashboard/screens/home_screen.dart';
import '../../features/transactions/screens/quick_entry_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/transactions/screens/movements_screen.dart';
import '../../features/transactions/utils/transaction_filter.dart';

import '../../features/analysis/screens/stats_screen.dart';
import '../../features/analysis/screens/prediction_screen.dart';

import '../../features/debts/screens/debt_screen.dart';
import '../../features/goals/screens/savings_goals_screen.dart';

import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/pin_screen.dart';

import '../../features/vault/screens/vault_screen.dart';
import '../../features/vault/widgets/vault_lock_gate.dart';
import '../state/app_state.dart';
import '../i18n/app_locale_controller.dart';
import '../../features/settings/screens/premium_screen.dart';
import '../../features/settings/screens/consent_screen.dart';
import '../../features/settings/screens/backup_screen.dart';
import '../../features/settings/screens/privacy_policy_screen.dart';
import '../../features/transactions/screens/recurring_screen.dart';

class AppRouter {
  /// Pantallas PRO (P-05 y las ocultas de D-013). Sin PRO, cualquier camino
  /// que llegue a ellas abre la pantalla Pro en su lugar.
  static const Set<String> proRoutes = {
    '/stats',
    '/goals',
    '/prediction',
    '/monthly_analysis',
  };

  static Route generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    // Cargar algo en la Bóveda también es PRO (Especificación §7).
    final bool wantsVault = args['isVault'] == true || args['mode'] == 'vault';
    if (!AppState.instance.isPro &&
        (proRoutes.contains(settings.name) ||
            (settings.name == '/add' && wantsVault))) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const PremiumScreen(),
      );
    }

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const QuickEntryScreen(),
        );

      case "/quick_entry":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const QuickEntryScreen(),
        );

      case "/dashboard":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case "/add":

        /// seguridad para evitar null crashes
        final bool isVault = args['isVault'] == true || args['mode'] == 'vault';

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddTransactionScreen(
            movimientoToEdit: args['movimientoToEdit'],
            isFromQuickEntry: args['isFromQuickEntry'] ?? false,
            type: args['initialTipo'] ?? args['type'],
            isVault: isVault,
            initialCategory: args['category'],
          ),
        );

      case "/vault":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VaultScreen(),
        );

      case "/movements":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MovementsScreen(
            initialFilter: args['filter'] as TransactionFilter?,
          ),
        );

      case "/stats":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const StatsScreen(),
        );

      case "/prediction":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PredictionScreen(),
        );

      case "/debts":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DebtScreen(),
        );

      case "/goals":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SavingsGoalsScreen(),
        );

      case "/settings":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );

      case "/pin":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PinScreen(
            isSetup: args['setup'] ?? false,
            isVault: args['isVault'] ?? false,
          ),
        );

      case "/premium":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PremiumScreen(),
        );

      case "/consent":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ConsentScreen(),
        );

      case "/backup":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BackupScreen(),
        );

      case "/privacy":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyScreen(),
        );

      case "/recurring":
        final bool vaultRecurring = args['isVault'] == true;
        return MaterialPageRoute(
          settings: settings,
          // Los pagos fijos de la Bóveda se tapan igual que la Bóveda.
          builder: (context) => vaultRecurring
              ? VaultLockGate(
                  title: AppLocaleController.instance.text('recurring_title'),
                  child: const RecurringScreen(isVault: true),
                )
              : const RecurringScreen(),
        );

      case "/monthly_analysis":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MonthlyAnalysisScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const QuickEntryScreen(),
        );
    }
  }
}
