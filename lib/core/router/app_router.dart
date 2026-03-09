import 'package:flutter/material.dart';

import '../../features/dashboard/screens/home_screen.dart';
import '../../features/transactions/screens/quick_entry_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/transactions/screens/movements_screen.dart';

import '../../features/analysis/screens/stats_screen.dart';
import '../../features/analysis/screens/prediction_screen.dart';

import '../../features/debts/screens/debt_screen.dart';
import '../../features/goals/screens/goal_screen.dart';
import '../../features/budgets/screens/budget_screen.dart';

import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/pin_screen.dart';

import '../../features/vault/screens/vault_screen.dart';
import '../../features/settings/screens/premium_screen.dart';
import '../../features/settings/screens/consent_screen.dart';
import '../../features/settings/screens/backup_screen.dart';
import '../../features/settings/screens/privacy_policy_screen.dart';

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

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
            initialTipo: args['initialTipo'] ?? args['type'],
            isVault: isVault,
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
          builder: (_) => const MovementsScreen(),
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
          builder: (_) => const GoalScreen(),
        );

      case "/budgets":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BudgetScreen(),
        );

      case "/settings":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );

      case "/pin":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PinScreen(),
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

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const QuickEntryScreen(),
        );
    }
  }
}
