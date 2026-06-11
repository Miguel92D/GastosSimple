import 'package:flutter/material.dart';
import '../app_text_styles.dart';

class GoldShimmerText extends StatefulWidget {
  final String text;
  final bool isPro;
  final double fontSize;

  const GoldShimmerText({
    super.key,
    required this.text,
    required this.isPro,
    this.fontSize = 28,
  });

  @override
  State<GoldShimmerText> createState() => _GoldShimmerTextState();
}

class _GoldShimmerTextState extends State<GoldShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _shineAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPro) {
      return Text(
        widget.text,
        style: AppTextStyles.titleLarge.copyWith(fontSize: widget.fontSize),
      );
    }

    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final shineCenter = 0.24 + (_shineAnimation.value * 0.52);
            const shineWidth = 0.22;

            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                shineCenter - shineWidth,
                shineCenter,
                shineCenter + shineWidth,
                1.0,
              ],
              colors: [
                const Color(0xFFD4AF37), // Metallic Gold
                const Color(0xFFD4AF37), // Metallic Gold
                const Color(0xFFFFFACD).withValues(alpha: 0.9), // Shine
                const Color(0xFFD4AF37), // Metallic Gold
                const Color(0xFFD4AF37), // Metallic Gold
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: widget.fontSize + 4,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      },
    );
  }
}
