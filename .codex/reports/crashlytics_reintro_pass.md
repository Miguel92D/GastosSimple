# Crashlytics Reintroduction Pass

Pass date: 2026-05-12

Scope: reintroduced Firebase Crashlytics only for the upcoming Play Store release. Firebase Analytics, Firebase Auth, Firestore, Google Sign-In, billing logic, signing, AAB generation, and broad refactors were intentionally left untouched.

## 1. Executive summary

Firebase Crashlytics was reintroduced cleanly as the only Firebase product SDK beyond Firebase Core. The app now initializes Firebase, registers Crashlytics fatal Flutter/platform error handlers, and records nonfatal errors from `ErrorService` while preserving the existing local file error log.

Firebase Analytics was not reintroduced. Auth/cloud SDKs remain absent. The rebuilt debug APK launched successfully, Settings opened, and the visible Settings flow still showed local-only backup behavior with no account, Google sign-in, cloud backup, or cloud restore controls.

## 2. Files modified

- `pubspec.yaml`
- `pubspec.lock`
- `.flutter-plugins-dependencies`
- `lib/main.dart`
- `lib/services/error_service.dart`
- `lib/firebase_options.dart`
- `android/app/build.gradle`
- `android/settings.gradle`
- `android/app/proguard-rules.pro`
- `android/app/google-services.json`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugins.cmake`
- `.codex/reports/crashlytics_reintro_pass.md`

## 3. Exact Crashlytics-only changes applied

- Added `firebase_core` and `firebase_crashlytics` dependencies.
- Ran `flutter pub get` to regenerate package metadata and plugin registrants.
- Restored `lib/firebase_options.dart` for the Android Firebase app options.
- Restored `android/app/google-services.json` for the existing Firebase Android app.
- Restored Android Gradle plugin declarations/applications for:
  - `com.google.gms.google-services`
  - `com.google.firebase.crashlytics`
- Restored Crashlytics-only ProGuard keep rules.
- Added Firebase initialization in `main()`.
- Added Crashlytics fatal Flutter error handler:
  - `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
- Added Crashlytics fatal platform error handler through `PlatformDispatcher.instance.onError`.
- Added nonfatal Crashlytics reporting in `ErrorService.logError(...)`.
- Kept the existing local file error log in `ErrorService`.

## 4. Confirmation that Analytics was not reintroduced

Confirmed.

Static checks found no matches for:

- `firebase_analytics`
- `FirebaseAnalytics`
- `logAppOpen`
- `logEvent(`
- Google app measurement / analytics package names in checked source/package metadata.

The debug APK manifest scan showed Firebase Core, Crashlytics, Firebase Sessions, Installations, and transport components expected from Crashlytics. It did not show Firebase Analytics or measurement entries.

## 5. Confirmation that auth/cloud SDKs remain absent

Confirmed.

Static checks found no matches for:

- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`
- `FirebaseAuth`
- `FirebaseFirestore`
- `GoogleSignIn`
- `AuthService`
- `CloudBackupService`
- `signInWithGoogle`
- `/auth`
- `AppRoutes.auth`

The debug APK manifest scan did not show Firebase Auth, Firestore, or Google Sign-In activities/components.

## 6. Runtime sanity check result

Passed for this scope.

- `flutter pub get`: passed.
- `dart format lib/main.dart lib/services/error_service.dart lib/firebase_options.dart`: passed.
- `flutter build apk --debug --no-pub`: passed.
- Installed `build/app/outputs/flutter-apk/app-debug.apk` on Samsung SM G990E, device id `R5CW51JJ10N`: passed.
- Launched `com.migueld.gastossimple/.MainActivity`: passed.
- `dumpsys window` confirmed focus on `com.migueld.gastossimple/.MainActivity`.
- App process was running.
- Opened dashboard from the quick-entry screen.
- Opened drawer and Settings.
- Settings displayed local-first controls including language, security, local backup, and currency.
- Visible Settings/Backup entry remained `Respaldo Local`; no Google account, sign-in, cloud backup, or cloud restore controls were visible.

## 7. Remaining privacy/Data Safety impact

Crashlytics now creates a Play Data Safety and privacy-policy disclosure requirement for crash diagnostics and related device/app identifiers/diagnostic data handled by Firebase Crashlytics. The app can still be described as local-only for financial records if the privacy policy clearly distinguishes local financial data storage from Crashlytics diagnostic reporting.

Analytics remains absent, so usage analytics/tracking should not be disclosed as active unless another SDK requires it. Auth/cloud account deletion remains out of scope for the first local-only release as long as sign-in/cloud account features remain absent.

## 8. Exact next safe action

Update the privacy policy and Play Data Safety draft to disclose Firebase Crashlytics diagnostics only, then proceed to release signing/AAB preparation after confirming the final dependency and merged release manifest still exclude Analytics, Auth, Firestore, and Google Sign-In.
