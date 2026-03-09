import 'package:flutter/material.dart';

class ErrorGuard extends StatelessWidget {
  final Widget child;

  const ErrorGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Algo salió mal.\nIntenta reiniciar la app.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    };

    return child;
  }
}
