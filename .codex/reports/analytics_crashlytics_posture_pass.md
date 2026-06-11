# Analytics Crashlytics Posture Pass

Audit date: 2026-05-12

Scope: focused Firebase Analytics and Crashlytics cleanup for the planned first local-only Android release. No signing work, AAB generation, billing changes, or broad refactors were done.

## 1. Executive summary

The safest v1 local-only posture is to remove Firebase Analytics and Firebase Crashlytics from the first release artifact, not merely keep them and disclose them. Before this pass, both SDKs were active: app startup initialized Firebase, logged an Analytics app-open event, registered Crashlytics fatal handlers, and `ErrorService` sent errors/events to Crashlytics/Analytics.

This pass removed those SDK dependencies, removed their Dart runtime calls, removed the Android Google Services and Crashlytics Gradle plugins, removed Firebase-specific ProGuard keep rules, and removed Firebase config files that only supported the removed Firebase runtime. The rebuilt debug APK launched and opened Settings successfully. Static scans of source/package metadata plus an APK manifest scan found no remaining Firebase Analytics, Crashlytics, Firebase Core, Google Services, or Crashlytics plugin entries in the checked release path.

## 2. Analytics decision

Firebase Analytics: removed for v1 local-only.

Reason: keeping Analytics would require Data Safety and privacy policy disclosure for app activity/usage collection and would contradict the current local-only privacy posture. Since the first release does not need telemetry to preserve core local expense tracking, removal is safer than disclosure-only retention.

## 3. Crashlytics decision

Crashlytics: removed for v1 local-only.

Reason: keeping Crashlytics would require disclosure of crash diagnostics/device-related data collection and would keep a third-party data flow active in a release whose user-facing privacy copy is local-only. The app still keeps local error logging through `ErrorService`, so removing Crashlytics does not break the local-only core flow.

## 4. Files modified

- `pubspec.yaml`
- `pubspec.lock`
- `.flutter-plugins-dependencies`
- `lib/main.dart`
- `lib/services/error_service.dart`
- `lib/firebase_options.dart` deleted
- `android/app/build.gradle`
- `android/settings.gradle`
- `android/app/proguard-rules.pro`
- `android/app/google-services.json` deleted
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugins.cmake`
- `.codex/reports/analytics_crashlytics_posture_pass.md`

## 5. Exact cleanup/disablement applied

- Removed `firebase_analytics`, `firebase_crashlytics`, and now-unused `firebase_core` dependencies from `pubspec.yaml`.
- Ran `flutter pub get` after cleanup so `pubspec.lock`, `.dart_tool/package_config.json`, `.flutter-plugins-dependencies`, and generated desktop plugin registrants no longer include Firebase plugins.
- Removed `Firebase.initializeApp(...)` and `DefaultFirebaseOptions` usage from startup.
- Removed `FirebaseAnalytics.instance.logAppOpen()` from startup.
- Removed Crashlytics fatal Flutter and platform error handlers from startup.
- Removed Crashlytics `recordError(...)` and Analytics `logEvent(...)` calls from `ErrorService`.
- Kept local file-based error logging in `ErrorService`.
- Removed `com.google.gms.google-services` and `com.google.firebase.crashlytics` from Android Gradle plugin application/declaration.
- Removed Firebase/Google Services/Auth/Firestore/Crashlytics/Analytics keep rules from `android/app/proguard-rules.pro`.
- Deleted unused Firebase config files: `lib/firebase_options.dart` and `android/app/google-services.json`.

## 6. Runtime sanity check result

Passed for this scope.

- `flutter clean`: passed.
- `flutter pub get`: passed.
- `flutter build apk --debug --no-pub`: passed.
- Installed rebuilt debug APK on Samsung SM G990E, device id `R5CW51JJ10N`: passed.
- Launched `com.migueld.gastossimple/.MainActivity`: passed, process running and focused.
- Opened dashboard from the quick-entry screen: passed.
- Opened drawer and Settings: passed.
- Settings still showed local-only settings and `Respaldo Local` as the backup entry point.

Artifact/static checks:

- `rg` over `pubspec.yaml`, `pubspec.lock`, `.dart_tool/package_config.json`, `.flutter-plugins-dependencies`, `lib`, and `android` found no Firebase Analytics, Crashlytics, Firebase Core, Google Services, or Crashlytics plugin references in the checked non-build files.
- `aapt dump xmltree build/app/outputs/flutter-apk/app-debug.apk AndroidManifest.xml` with filters for `firebase`, `crashlytics`, `analytics`, and `measurement` returned no matches.

## 7. Remaining privacy/Data Safety risk, if any

Analytics/Crashlytics no longer create a first-release Play Data Safety risk after this pass.

Remaining non-Firebase Data Safety/privacy items still need final release disclosure review: billing/in-app purchase, local export/share/import, file picker, local auth/biometrics, notifications, secure storage, URL launcher, and any permissions merged into the final release AAB. These are outside this pass.

## 8. Exact next safe action

Run a final Play Data Safety and privacy-policy alignment pass against the now Firebase-free local-only artifact, then proceed to release signing setup and signed AAB generation only after the declarations and privacy URL match the final dependency set.
