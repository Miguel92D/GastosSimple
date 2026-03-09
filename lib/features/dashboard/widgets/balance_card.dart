import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/ui_factory.dart';
import '../../../core/state/app_mode_controller.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isVault;

  const BalanceCard({super.key, required this.balance, required this.isVault});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: UIFactory.dashboardCard(
        isVault: isVault,
        child: Column(
          children: [
            Text(
              ((isVault || AppModeController.instance.isVault)
                      ? "Balance privado"
                      : "Balance mensual")
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "\$${balance.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
