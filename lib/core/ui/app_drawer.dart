import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../flow/general_flow_service.dart';
import '../../core/state/app_state.dart';
import '../controllers/action_controller.dart';
import '../controllers/app_action.dart';
import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_text_styles.dart';
import 'widgets/gold_shimmer_text.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPro = AppState.instance.isPro;

    return Drawer(
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              gradient: isPro
                  ? AppGradients.primaryGradient
                  : AppGradients.glassGradient,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.textPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _WavePainter(_waveController.value),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                GoldShimmerText(text: '\$imple', isPro: isPro, fontSize: 28),
                Text(
                  'CONTROL FINANCIERO',
                  style: AppTextStyles.subLabel.copyWith(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPro
                            ? AppColors.incomeGreen
                            : AppColors.softText,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isPro)
                            BoxShadow(
                              color: AppColors.incomeGreen.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPro ? 'CUENTA PREMIUM' : 'CUENTA GRATIS',
                      style: AppTextStyles.subLabel.copyWith(
                        fontSize: 11,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openDashboard();
                  },
                ),
                _DrawerItem(
                  icon: Icons.swap_vert_rounded,
                  title: 'Movimientos',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openMovements();
                  },
                ),
                _DrawerItem(
                  icon: Icons.analytics_rounded,
                  title: 'Estadísticas',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openStats);
                  },
                ),
                _DrawerItem(
                  icon: Icons.flag_rounded,
                  title: 'Metas de ahorro',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openGoals();
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [
                              _shimmerController.value - 0.2,
                              _shimmerController.value,
                              _shimmerController.value + 0.2,
                            ],
                            colors: [
                              const Color(0xFFD4AF37),
                              const Color(0xFFFFFACD).withOpacity(0.9),
                              const Color(0xFFD4AF37),
                            ],
                          ).createShader(bounds);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _DrawerItem(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Inteligencia AI',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openPrediction();
                  },
                ),
                _DrawerItem(
                  icon: Icons.account_balance_rounded,
                  title: 'Deudas',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openDebts();
                  },
                ),
                _DrawerItem(
                  icon: Icons.lock_rounded,
                  title: 'Bóveda',
                  onTap: () {
                    GeneralFlowService.goBack();
                    ActionController.execute(context, AppAction.openVault);
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Ajustes',
                  onTap: () {
                    GeneralFlowService.goBack();
                    GeneralFlowService.openSettings();
                  },
                ),
              ],
            ),
          ),
        ],
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
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final double yCenter = size.height * 0.5;
    final double amplitude = 8.0;

    path.moveTo(0, yCenter);

    for (double x = 0; x <= size.width; x += 2) {
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + amplitude * math.sin(waveExpression);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Secondary line
    final secondaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final secondaryPath = Path();
    secondaryPath.moveTo(0, yCenter + 8);
    for (double x = 0; x <= size.width; x += 2) {
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) - (animationValue * 2 * math.pi);
      final double y =
          yCenter + 8 + (amplitude * 0.5) * math.cos(waveExpression);
      secondaryPath.lineTo(x, y);
    }
    canvas.drawPath(secondaryPath, secondaryPaint);

    // Glowing dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 1; i < 3; i++) {
      final x = (size.width / 3) * i;
      final double normalizedX = x / size.width;
      final double waveExpression =
          (normalizedX * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + amplitude * math.sin(waveExpression);

      canvas.drawCircle(Offset(x, y), 4, glowPaint);
      canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: AppColors.softText.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMain.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
