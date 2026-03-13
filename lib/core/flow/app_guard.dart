import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../error/exceptions.dart';
import '../../services/error_service.dart';
import '../i18n/app_locale_controller.dart';

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

  static Future<bool> runWithFeedback(BuildContext context, Future<void> Function() action, {String? successMessage, String? errorMessage}) async {
    final l10n = context.read<AppLocaleController>();
    final actualErrorMessage = errorMessage ?? l10n.text('error_occurred_desc');

    try {
      await action();
      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Colors.green));
      }
      return true;
    } on DatabaseException catch (e, stack) {
      debugPrint("DB Exception trapped: $e");
      ErrorService.instance.logError(e, stack);
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.text('error_saving_data')), backgroundColor: Colors.redAccent));
      }
      return false;
    } catch (e, stack) {
      debugPrint("AppGuard feedback error: $e");
      ErrorService.instance.logError(e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(actualErrorMessage), backgroundColor: Colors.redAccent));
      }
      return false;
    }
  }
}
