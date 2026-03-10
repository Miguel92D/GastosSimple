import 'package:flutter/material.dart';
import 'glass_card.dart';

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
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;
  final Widget? prefix;

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
    this.focusNode,
    this.onSubmitted,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 24,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: style ?? const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 16,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white.withOpacity(0.7), size: 20)
              : null,
          prefix: prefix,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
