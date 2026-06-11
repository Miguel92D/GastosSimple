# Auth/Cloud SDK Cleanup Pass

Audit date: 2026-05-12

Scope: focused cleanup for the first local-only release artifact. Only `firebase_auth`, `cloud_firestore`, and `google_sign_in` were targeted. Firebase Analytics and Crashlytics were intentionally left untouched. No signing work or AAB generation was performed.

## 1. Executive summary

The unused auth/cloud SDKs were removed from the first local-only release dependency graph.

Direct dependencies on `firebase_auth`, `cloud_firestore`, and `google_sign_in` were removed from `pubspec.yaml` and `pubspec.lock`. The hidden, unreachable source files that imported those packages were removed:

- `lib/services/auth_service.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/auth/screens/auth_screen.dart`

The current local-only UX remains intact: app launch works, dashboard opens, Settings opens, and Settings still exposes local backup only. No Google account, Google sign-in, cloud backup, cloud restore, `/auth`, `AuthService`, or `CloudBackupService` path remains in normal source search.

## 2. SDK-by-SDK decision

| SDK | Decision | Reason |
| --- | --- | --- |
| `firebase_auth` | Removed | Not user-reachable, not registered in startup, no `/auth` route, no account deletion flow planned for first local-only release. Keeping it only increased Play account/Data Safety ambiguity. |
| `cloud_firestore` | Removed | Cloud backup is not shipping in v1; local backup/export/import remains. Firestore upload code could handle sensitive financial/vault data if accidentally reconnected. |
| `google_sign_in` | Removed | Google account sign-in is not shipping in the first local-only release. Removing it keeps account deletion out of scope for v1. |

## 3. Files modified

- `pubspec.yaml`
- `pubspec.lock`
- `lib/services/cloud_backup_service.dart` deleted
- `lib/services/auth_service.dart` deleted from workspace
- `lib/features/auth/screens/auth_screen.dart` deleted from workspace
- `.codex/reports/auth_cloud_sdk_cleanup_pass.md`

Note: `lib/services/auth_service.dart` and `lib/features/auth/screens/auth_screen.dart` were untracked files before this pass, so Git status does not show them as tracked deletions.

## 4. Exact cleanup applied

- Removed direct `pubspec.yaml` dependencies:
  - `firebase_auth`
  - `cloud_firestore`
  - `google_sign_in`
- Regenerated package resolution with `flutter pub get`.
- Removed resolved lockfile entries for:
  - `firebase_auth`
  - `firebase_auth_platform_interface`
  - `firebase_auth_web`
  - `cloud_firestore`
  - `cloud_firestore_platform_interface`
  - `cloud_firestore_web`
  - `google_sign_in`
  - `google_sign_in_android`
  - `google_sign_in_ios`
  - `google_sign_in_platform_interface`
  - `google_sign_in_web`
  - `google_identity_services_web`
- Deleted hidden auth/cloud Dart source files that imported the removed packages.
- Ran `flutter clean`, `flutter pub get`, and rebuilt debug APK to clear stale package/plugin state.

## 5. What was removed vs disabled

Removed:

- `firebase_auth` dependency and transitive package entries.
- `cloud_firestore` dependency and transitive package entries.
- `google_sign_in` dependency and transitive package entries.
- Hidden AuthService code.
- Hidden CloudBackupService code.
- Hidden AuthScreen code.

Disabled:

- Nothing new was disabled in source during this pass. Strategy B had already disabled runtime integration points by removing `/auth`, provider registration, Settings account entry, Backup cloud actions, and transaction auto-cloud backup calls.

Left unchanged intentionally:

- Firebase Core.
- Firebase Analytics.
- Firebase Crashlytics.
- `firebase_options.dart`.
- Android Gradle Google services and Crashlytics plugins.
- Local backup/export/import.
- Premium billing.
- Local PIN/biometric security.
- Notifications.

## 6. Runtime sanity check result

Passed for this scope.

Commands/checks run:

- `flutter pub get` completed successfully after the dependency cleanup.
- `flutter build apk --debug --no-pub` completed successfully after `flutter clean`.
- Installed `build/app/outputs/flutter-apk/app-debug.apk` on device `R5CW51JJ10N`.
- Launched `com.migueld.gastossimple/.MainActivity`.
- `dumpsys window` confirmed focus on `com.migueld.gastossimple/.MainActivity`.
- Opened dashboard from quick-entry.
- Opened drawer and tapped `Ajustes`.
- Settings opened successfully.
- Settings visible content showed language, security, local backup, and currency.
- Settings visible content did not show Google account, Google sign-in, cloud backup, or cloud restore.

Static verification:

- `rg` found no `firebase_auth`, `cloud_firestore`, `google_sign_in`, `FirebaseAuth`, `FirebaseFirestore`, `GoogleSignIn`, `AuthService`, `CloudBackupService`, `signInWithGoogle`, `/auth`, or `AppRoutes.auth` references in `pubspec.yaml`, `pubspec.lock`, `.dart_tool/package_config.json`, `.flutter-plugins-dependencies`, `lib`, or Android source outside generated `build`.
- `aapt dump xmltree build/app/outputs/flutter-apk/app-debug.apk AndroidManifest.xml` showed Firebase Core/Analytics/Crashlytics entries only; it did not show Firebase Auth activities, Firestore registrars, or Google Sign-In activities.

Note: one generated intermediate merged manifest file under `android/app/build/intermediates/...` still displayed stale Auth/Firestore/Sign-In entries even after rerunning manifest tasks. The APK manifest itself was checked with `aapt` and is the authoritative artifact for this debug sanity check.

## 7. Remaining risk, if any

- Firebase Analytics and Crashlytics remain active and still need a separate privacy/Data Safety decision, as planned.
- `firebase_options.dart`, `google-services.json`, Google services Gradle plugin, and Crashlytics Gradle plugin remain because Analytics/Crashlytics were out of scope.
- A release merged manifest still needs to be generated and reviewed later; this pass only built and inspected a debug APK.
- Auth/cloud functionality has been removed from the first-release source path. If cloud backup returns later, it must be rebuilt with account deletion, cloud data deletion, restore behavior, consent, privacy copy, and Firestore rules.

## 8. Exact next safe action

Run the next focused privacy posture pass for Firebase Analytics and Crashlytics: decide whether to keep them and disclose diagnostics/analytics accurately, or remove/disable them to preserve the strictest local-only privacy claim. Do not begin signing until that decision and the privacy/Data Safety draft are complete.
