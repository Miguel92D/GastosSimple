import 'package:flutter/material.dart';
import '../error/exceptions.dart';
import '../../services/error_service.dart';

class AppGuard {
  static Future<T?> runSafe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, stack) {
      debugPrint("AppGuard error: $e");
      ErrorService.instance.logError(e, stack);
      return null;
    }
  }

  static Future<bool> runWithFeedback(BuildContext context, Future<void> Function() action, {String? successMessage, String errorMessage = "Ha ocurrido un error inesperado"}) async {
    try {
      await action();
      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Colors.green));
      }
      return true;
    } on DatabaseException catch (e, stack) {
      debugPrint("DB Exception trapped: \$e");
      ErrorService.instance.logError(e, stack);
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error guardando datos. Intenta de nuevo.'), backgroundColor: Colors.redAccent));
      }
      return false;
    } catch (e, stack) {
      debugPrint("AppGuard feedback error: \$e");
      ErrorService.instance.logError(e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent));
      }
      return false;
    }
  }
}
