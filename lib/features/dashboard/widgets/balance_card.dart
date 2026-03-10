import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/design/app_colors.dart';
import '../../../core/state/app_mode_controller.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isVault;

  const BalanceCard({super.key, required this.balance, required this.isVault});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: GlassCard(
        glowColor: AppColors.primaryStart,
        gradientColors: [
          AppColors.primaryStart.withValues(alpha: 0.8),
          AppColors.primaryEnd.withValues(alpha: 0.6),
        ],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ((isVault || AppModeController.instance.isVault)
                          ? "Balance privado"
                          : "Balance mensual")
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  isVault
                      ? Icons.lock_outline_rounded
                      : Icons.account_balance_wallet_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "\$${balance.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
