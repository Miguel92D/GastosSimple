import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'glass_card.dart';
import '../design/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isNegative;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    this.title = "Balance disponible",
    this.subtitle = "Marzo 2026",
    this.icon = Icons.account_balance_wallet_rounded,
    this.isNegative = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 24,
        glowColor: AppColors.primaryStart.withOpacity(0.2),
        gradientColors: [
          AppColors.primaryStart.withOpacity(0.8),
          AppColors.primaryEnd.withOpacity(0.6),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "\$",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  NumberFormat('#,###', 'es_ES').format(balance.abs()),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
