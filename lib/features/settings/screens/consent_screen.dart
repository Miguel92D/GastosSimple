import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_locale_controller.dart';
import '../../../core/router/navigation_service.dart';
import '../../../core/state/app_state.dart';

/// Se muestra una sola vez (desde InitialGuard). Crashlytics arranca apagado
/// (ver AndroidManifest) y solo se activa si el usuario acepta.
class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 32),
              Text(
                l10n.text('consent_title'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.text('consent_body'),
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => AppState.instance.setConsent(crashReports: true),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.text('consent_accept'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    AppState.instance.setConsent(crashReports: false),
                child: Text(l10n.text('consent_decline')),
              ),
              TextButton(
                onPressed: () => NavigationService.navigate("/privacy"),
                child: Text(
                  l10n.text('consent_privacy'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
