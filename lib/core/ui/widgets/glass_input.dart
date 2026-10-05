import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../glass_card.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_radius.dart';
import '../app_spacing.dart';

class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final Function(String)? onChanged;
  final bool isCenter;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;
  final VoidCallback? onEditingComplete;
  final Widget? prefix;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  /// Campo que no se escribe: abre algo al tocarlo (por ejemplo, un calendario).
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;

  const GlassInput({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.isCenter = false,
    this.style,
    this.hintStyle,
    this.focusNode,
    this.onSubmitted,
    this.onEditingComplete,
    this.prefix,
    this.height,
    this.padding,
    this.textInputAction,
    this.inputFormatters,
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: height,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      borderRadius: AppRadius.xl,
      glowColor: AppColors.primaryPurple.withValues(alpha: 0.02),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          autofocus: autofocus,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction ?? TextInputAction.done,
          maxLines: maxLines,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted?.call(),
          onEditingComplete: onEditingComplete,
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
          style: style ?? AppTextStyles.bodyMain.copyWith(fontSize: 16),
          decoration: InputDecoration(
            labelText: label.isEmpty ? null : label,
            labelStyle: AppTextStyles.subLabel.copyWith(
              color: AppColors.softText.withValues(alpha: 0.65),
            ),
            hintText: hintText,
            hintStyle:
                hintStyle ??
                AppTextStyles.bodyMain.copyWith(
                  color: AppColors.softText.withValues(alpha: 0.4),
                ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: AppColors.softText.withValues(alpha: 0.6),
                    size: 18,
                  )
                : null,
            prefix: prefix,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
