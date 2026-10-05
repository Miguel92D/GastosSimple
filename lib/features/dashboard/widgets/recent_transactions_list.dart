import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/widgets/transaction_history_list.dart';
import '../../../core/ui/widgets/app_section_title.dart';
import '../../../core/ui/app_spacing.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onRefresh;

  /// Título de la sección (ej. "Movimientos de hoy"). Si es null se usa
  /// "Movimientos recientes".
  final String? title;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.onRefresh,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: AppSectionTitle(
            title ??
                context.watch<AppLocaleController>().text('recent_movements'),
          ),
        ),
        Padding(
          // sm + el md propio de cada tile = lg (24): los movimientos quedan
          // alineados con la tarjeta de balance y las de Ingreso/Gasto.
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: TransactionHistoryList(
            transactions: transactions,
            onRefresh: onRefresh,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }
}
