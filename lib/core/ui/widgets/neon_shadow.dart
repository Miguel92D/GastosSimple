import 'package:flutter/material.dart';

class NeonShadow extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;
  final Offset offset;

  const NeonShadow({
    super.key,
    required this.child,
    required this.glowColor,
    this.blurRadius = 24.0,
    this.spreadRadius = 1.0,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: child,
    );
  }
}
