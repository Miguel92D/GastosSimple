import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class QuickEntryScreen extends StatefulWidget {
  const QuickEntryScreen({super.key});

  @override
  State<QuickEntryScreen> createState() => _QuickEntryScreenState();
}

class _QuickEntryScreenState extends State<QuickEntryScreen>
    with SingleTickerProviderStateMixin {
  double _balance = 0;
  late AnimationController _mouthController;
  final DashboardController _dashboardController = DashboardController();

  @override
  void initState() {
    super.initState();
    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _checkPendingAction();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _dashboardController.getBalance(false);
    if (mounted) {
      setState(() {
        _balance = balance;
      });
    }
  }

  @override
  void dispose() {
    _mouthController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingAction() async {
    final prefs = await SharedPreferences.getInstance();
    final action = prefs.getString('pending_action');

    if (action == 'quick_entry' && mounted) {
      final type = prefs.getString('pending_type') ?? 'gasto';

      await prefs.remove('pending_action');
      await prefs.remove('pending_type');

      if (mounted) {
        ActionController.execute(
          context,
          type == 'ingreso' ? AppAction.addIncome : AppAction.addExpense,
          arguments: {"isFromQuickEntry": true},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    return AppScaffold(
      title: "",
      body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl + 8,
                    ),
                    child: Text(
                      l10n.text('quick_entry_question'),
                      style: AppTextStyles.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl + 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionCard(
                        context: context,
                        icon: Icons.add_rounded,
                        color: AppColors.incomeGreen,
                        onTap: () {
                          ActionController.execute(
                            context,
                            AppAction.addIncome,
                            arguments: {"isFromQuickEntry": true},
                          );
                          // Give it a small delay since action might be navigating
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            _loadBalance,
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.xl + 8),
                      _buildActionCard(
                        context: context,
                        icon: Icons.remove_rounded,
                        color: AppColors.expenseRed,
                        onTap: () {
                          ActionController.execute(
                            context,
                            AppAction.addExpense,
                            arguments: {"isFromQuickEntry": true},
                          );
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            _loadBalance,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // THE MOUTH
                  AnimatedBuilder(
                    animation: _mouthController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(120, 40),
                        painter: _MouthPainter(
                          balance: _balance,
                          animationValue: _mouthController.value,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 64),
                  _buildDashboardButton(context),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        width: 100,
        height: 100,
        padding: EdgeInsets.zero,
        borderRadius: 32,
        glowColor: color.withValues(alpha: 0.3),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2.0),
        child: Center(child: Icon(icon, color: color, size: 48)),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return GestureDetector(
      onTap: () => ActionController.execute(context, AppAction.openDashboard),
      child: GlassCard(
        width: 80,
        height: 80,
        borderRadius: 32,
        padding: EdgeInsets.zero,
        glowColor: AppColors.primaryPurple.withValues(alpha: 0.4),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.5),
          width: 2.0,
        ),
        child: const Center(
          child: Icon(
            Icons.grid_view_rounded,
            color: AppColors.primaryPurple,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _MouthPainter extends CustomPainter {
  final double balance;
  final double animationValue;

  _MouthPainter({required this.balance, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Color color;
    final double curveDirection;
    final bool isNeutral = balance == 0;

    if (balance > 0) {
      color = AppColors.incomeGreen;
      curveDirection = 1.0; // Happy smile
    } else if (balance < 0) {
      color = AppColors.expenseRed;
      curveDirection = -1.0; // Sad frown
    } else {
      color = AppColors.primaryPurple; // Coherent brand color
      curveDirection = 0.0; // Neutral straight line
    }

    final paint = Paint()
      ..color = color.withValues(alpha: 0.9 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    // Neon Glow - Enhanced for neutral state to be more visible
    final glowPaint = Paint()
      ..color = color.withValues(alpha: (isNeutral ? 0.4 : 0.25) * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isNeutral ? 14 : 12
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isNeutral ? 10 : 8);

    final path = Path();
    final double midY = size.height * 0.4;

    final double currentCurveHeight =
        (size.height * 0.6) * curveDirection * animationValue;

    path.moveTo(0, midY);
    path.quadraticBezierTo(
      size.width / 2,
      midY + currentCurveHeight,
      size.width,
      midY,
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MouthPainter oldDelegate) =>
      oldDelegate.balance != balance ||
      oldDelegate.animationValue != animationValue;
}
