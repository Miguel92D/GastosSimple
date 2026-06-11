import 'package:flutter/material.dart';

/// Envoltorio de protección de la app (Regla de Oro #7).
///
/// La pantalla de recuperación localizada se configura una sola vez en
/// `main.dart` mediante `ErrorWidget.builder` + `ErrorService`. Este widget
/// no debe sobreescribir ese builder: hacerlo reemplazaba el mensaje
/// localizado por un texto fijo.
class ErrorGuard extends StatelessWidget {
  final Widget child;

  const ErrorGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
