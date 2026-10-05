import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import '../core/ui/app_colors.dart';
import '../core/ui/app_text_styles.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

class ErrorService {
  static final ErrorService instance = ErrorService._init();
  ErrorService._init();

  Future<void> logError(Object error, StackTrace? stack) async {
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack);

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
    final l10n = context.read<AppLocaleController>();
    return Material(
      color: AppColors.darkBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.error,
                size: 80,
                color: AppColors.expenseRed,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.text('something_went_wrong'),
                style: AppTextStyles.titleMain.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.text('error_occurred_desc'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // In a real app, maybe attempt to navigate home or restart
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(l10n.text('back_to_start')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
