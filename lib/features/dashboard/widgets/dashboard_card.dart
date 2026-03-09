import 'package:flutter/material.dart';
import '../../../core/ui/design/app_design.dart';
import '../../../core/ui/design/pro_design.dart';
import '../../../core/state/app_mode_controller.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;

  const DashboardCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isPro = AppModeController.instance.isPro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPro
              ? ProDesign.dashboardGradient
              : AppDesign.dashboardGradient,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isPro
                        ? ProDesign.dashboardGradient.first
                        : AppDesign.dashboardGradient.first)
                    .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
