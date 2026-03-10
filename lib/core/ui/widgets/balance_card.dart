/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../glass_card.dart';
import '../app_colors.dart';
import '../app_gradients.dart';
import '../app_text_styles.dart';
import '../app_spacing.dart';
import '../app_radius.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    this.title = "BALANCE MENSUAL",
    this.subtitle = "Marzo 2026",
    this.onTap,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine target color based on balance
    final Color targetColor = widget.balance > 0
        ? AppColors.incomeGreen
        : widget.balance < 0
        ? AppColors.expenseRed
        : AppColors.softText;

    return GestureDetector(
      onTap: widget.onTap,
      child: GlassCard(
        width: double.infinity,
        borderRadius: AppRadius.xl,
        gradientColors: AppGradients.primaryGradient.colors,
        glowColor: AppColors.primaryPurple.withOpacity(0.35),
        padding: EdgeInsets.zero, // Padding handled by internal Padding widget
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              // 1 — Animated Wave Background
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _WavePainter(_waveController.value),
                      );
                    },
                  ),
                ),
              ),

              // 2 — Balance Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1 — Title
                      Text(
                        widget.title.toUpperCase(),
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 2 — Main Amount (Animated)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: widget.balance),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, child) {
                          final String sign = animatedValue >= 0 ? '+' : '-';
                          final String formattedValue = NumberFormat(
                            '#,###',
                            'es_ES',
                          ).format(animatedValue.abs().round());

                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            style: AppTextStyles.balanceAmount.copyWith(
                              color: targetColor,
                              fontSize: 42,
                            ),
                            child: Text("$sign\$$formattedValue"),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // 3 — Month Label (Pill style)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(
                          widget.subtitle,
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    final double yCenter = size.height * 0.65;
    final double amplitude = 18.0;

    path.moveTo(0, yCenter);

    for (double x = 0; x <= size.width; x += 1) {
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + amplitude * math.sin(waveExpression);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw secondary fainter line
    final secondaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final secondaryPath = Path();
    secondaryPath.moveTo(0, yCenter + 15);
    for (double x = 0; x <= size.width; x += 1) {
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) - (animationValue * 2 * math.pi);
      final double y =
          yCenter + 15 + (amplitude * 0.6) * math.cos(waveExpression);
      secondaryPath.lineTo(x, y);
    }
    canvas.drawPath(secondaryPath, secondaryPaint);

    // Draw glowing dots along the main path
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 1; i < 4; i++) {
      final x = (size.width / 4) * i;
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + amplitude * math.sin(waveExpression);

      canvas.drawCircle(Offset(x, y), 5, glowPaint);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
