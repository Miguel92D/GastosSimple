import 'package:flutter/material.dart';

class SmartBuilder extends StatelessWidget {
  final Listenable listenable;
  final Widget Function(BuildContext) builder;

  const SmartBuilder({
    super.key,
    required this.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        return builder(context);
      },
    );
  }
}
