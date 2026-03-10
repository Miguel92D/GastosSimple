import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDesign {
  static bool isPro = false;

  static double get cardRadius => 24.0;

  static List<Color> get dashboardGradient => [
    AppColors.primaryStart,
    AppColors.primaryEnd,
  ];
}
