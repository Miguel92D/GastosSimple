/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/glass_card.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              AppColors.primaryPurple.withOpacity(0.1),
              AppColors.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl + 8,
                ),
                child: Text(
                  l10n.quick_entry_question,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
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
              const SizedBox(height: 40),
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
              const Spacer(),
              _buildDashboardButton(context),
              const SizedBox(height: AppSpacing.xxl),
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
        glowColor: color.withOpacity(0.3),
        border: Border.all(color: color.withOpacity(0.4), width: 2.0),
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
        glowColor: AppColors.primaryPurple.withOpacity(0.4),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.5),
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
    final Color color = balance >= 0
        ? AppColors.incomeGreen
        : AppColors.expenseRed;

    final paint = Paint()
      ..color = color.withOpacity(0.8 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Neon Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final double midY = size.height / 2;
    // Curvature: positive balance = happy (downward arc), negative = sad (upward arc)
    final double curveOffset = balance >= 0 ? size.height : -size.height;
    final double currentCurve = curveOffset * animationValue;

    path.moveTo(0, midY);
    path.quadraticBezierTo(
      size.width / 2,
      midY + currentCurve,
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
