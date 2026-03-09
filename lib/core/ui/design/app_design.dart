import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDesign {
  static bool isPro = false;

  static double get cardRadius => 16.0;

  static List<Color> get dashboardGradient => [
    AppColors.primary,
    AppColors.primary.withValues(alpha: 0.8),
  ];
}
