/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Brand Identity Gradient
  static const primaryGradient = LinearGradient(
    colors: [
      Color(0xFF6F4DFF), // Primary Start
      Color(0xFF9A7BFF), // Primary End
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final progressGradient = LinearGradient(
    colors: [
      const Color(0xFF3DDC97), // incomeGreen
      const Color(0xFF7B5CFF), // primaryPurple
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Glassmorphism Base Gradient
  static const glassGradient = LinearGradient(
    colors: [
      Color(0x22FFFFFF), // 13% White
      Color(0x11FFFFFF), // 7% White
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surface & Accent Gradients (Optional additional)
  static const softGlassGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // States Backgrounds
  static final incomeGradient = LinearGradient(
    colors: [
      const Color(0xFF3DDC97).withValues(alpha: 0.15),
      const Color(0xFF3DDC97).withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final expenseGradient = LinearGradient(
    colors: [
      const Color(0xFFFF5C5C).withValues(alpha: 0.15),
      const Color(0xFFFF5C5C).withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Depth Gradient
  static RadialGradient get mainBackgroundRadial => RadialGradient(
    center: const Alignment(0.4, -0.7), // Offset for more dynamic look
    radius: 1.5,
    colors: [
      AppColors.primaryPurple.withValues(alpha: 0.25), // Stronger glow
      AppColors.primaryPurple.withValues(alpha: 0.08), // Middle layer
      AppColors.darkBackground,                  // Edge
    ],
    stops: const [0.0, 0.4, 1.0],
  );

  // Helper methods
  static LinearGradient primary() => primaryGradient;
  static LinearGradient glass() => glassGradient;
}
