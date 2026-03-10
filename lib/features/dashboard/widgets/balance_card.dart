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
        borderRadius: 24,
        glowColor: AppColors.primaryStart.withOpacity(0.3),
        gradientColors: [
          AppColors.primaryStart.withOpacity(0.9),
          AppColors.primaryEnd.withOpacity(0.7),
        ],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ((isVault || AppModeController.instance.isVault)
                              ? "Balance privado"
                              : "Balance disponible")
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy', 'es_ES').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVault
                        ? Icons.lock_outline_rounded
                        : Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "\$",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  NumberFormat('#,###', 'es_ES').format(balance.abs()),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
