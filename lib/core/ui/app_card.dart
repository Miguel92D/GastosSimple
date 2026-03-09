import 'package:flutter/material.dart';
import 'design/app_design.dart';
import 'design/pro_design.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        boxShadow: AppDesign.isPro
            ? [ProDesign.proGlow]
            : [const BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: child,
    );
  }
}
