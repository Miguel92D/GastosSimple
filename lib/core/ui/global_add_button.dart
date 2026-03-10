import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlobalAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GlobalAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      onPressed: onPressed,
      child: const Icon(Icons.add_rounded, color: AppColors.textPrimary),
    );
  }
}
