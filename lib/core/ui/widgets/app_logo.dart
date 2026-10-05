import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'gold_shimmer_text.dart';

/// El nombre `$imple`. Dorado y con brillo cuando hay Pro; lo decide solo.
class AppLogo extends StatelessWidget {
  final double fontSize;

  /// Logo del título de pantalla (inicio).
  const AppLogo({super.key}) : fontSize = 24;

  /// Logo grande del menú lateral.
  const AppLogo.drawer({super.key}) : fontSize = 28;

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<AppState>().isPro;
    return GoldShimmerText(text: '\$imple', isPro: isPro, fontSize: fontSize);
  }
}
