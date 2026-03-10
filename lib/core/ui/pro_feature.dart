import 'package:flutter/material.dart';
import '../../services/pro_service.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class ProFeature extends StatelessWidget {
  final Widget child;

  const ProFeature({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (ProService.instance.isPro) {
      return child;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 64, color: AppColors.orange),
          const SizedBox(height: 20),
          Text("Función PRO", style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Text(
            "Actualiza para desbloquear esta función",
            style: AppTextStyles.bodyMain.copyWith(color: AppColors.softText),
          ),
        ],
      ),
    );
  }
}
