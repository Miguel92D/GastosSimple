import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ErrorService {
  static final ErrorService instance = ErrorService._init();
  ErrorService._init();

  Future<void> logError(Object error, StackTrace? stack) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/error_logs.txt');
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final logEntry = '[$now] ERROR: $error\nSTACKTRACE: $stack\n\n';

      await file.writeAsString(logEntry, mode: FileMode.append);
      debugPrint('Error logged locally.');
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  Widget getErrorWidget(BuildContext context, FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Algo salió mal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Lo sentimos, ha ocurrido un error inesperado. Intenta nuevamente o reinicia la aplicación.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // In a real app, maybe attempt to navigate home or restart
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
