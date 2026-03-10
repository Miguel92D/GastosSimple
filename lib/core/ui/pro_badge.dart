import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "PRO",
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
