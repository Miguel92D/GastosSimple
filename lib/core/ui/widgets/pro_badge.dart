import 'package:flutter/material.dart';

class ProBadge extends StatefulWidget {
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;

  const ProBadge({
    super.key,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = 6,
  });

  @override
  State<ProBadge> createState() => _ProBadgeState();
}

class _ProBadgeState extends State<ProBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _controller.value - 0.2,
                _controller.value,
                _controller.value + 0.2,
              ],
              colors: [
                const Color(0xFFD4AF37), // Metallic Gold
                const Color(0xFFFFFACD).withValues(alpha: 0.9), // Shine
                const Color(0xFFD4AF37), // Metallic Gold
              ],
            ).createShader(bounds);
          },
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.0,
              ),
            ),
            child: Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: widget.fontSize,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
