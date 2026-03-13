import 'package:flutter/material.dart';

class ProBadge extends StatefulWidget {
  const ProBadge({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              // Using a thick border and semi-transparent fill so the shader colors everything
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Text(
              "PRO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
