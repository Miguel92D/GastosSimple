# Play Store Readiness Audit

Audit date: 2026-05-11

Official references checked:
- Target API requirement: https://developer.android.com/google/play/requirements/target-sdk
- Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Account deletion: https://support.google.com/googleplay/android-developer/answer/13327111
- App signing: https://developer.android.com/studio/publish/app-signing
- Android App Bundle: https://developer.android.com/guide/app-bundle

## A) Executive summary

The Android project is structurally close to Play-ready because it has a valid Flutter Android project, a consistent Android package ID, current compile/target SDK values, Firebase Android config, and release build settings.

It is blocked for Play release by policy and release-process issues: no verified release signing setup, no verified `.aab`, privacy copy contradicts actual SDK behavior, Data safety declarations are required, account deletion likely applies because Google sign-in is available, and test purchase fallback behavior must be removed.

Release readiness estimate: 38/100.

## B) What is already good

- `applicationId`, Android manifest package, and Firebase Android package match: `com.migueld.gastossimple`.
- `versionName` and `versionCode` are currently aligned between `pubspec.yaml` (`1.1.0+3`) and `android/app/build.gradle` (`1.1.0`, `3`).
- `compileSdk` and `targetSdk` are both `36`, which is above the current Google Play requirement that new apps and updates target Android 15/API 35 or higher.
- The app uses a standard Flutter Android Gradle project and should be capable of producing an Android App Bundle after signing is fixed and build verification passes.
- No ad SDK was detected.
- Debug banner is disabled in the Flutter app.

## C) What is incomplete

- Release signing is not configured with a real upload keystore in the repository environment.
- `flutter build appbundle --release` was not run in this read-only pass, so AAB readiness is unproven.
- Play Data safety answers are not prepared.
- Account deletion/data deletion path is missing.
- The app privacy policy screen and linked privacy policy likely need updates before Play submission.
- Permissions need final merged-manifest verification from a release build.
- Notification permission handling on Android 13+ needs verification.
- Google Play billing setup for `simple_pro_lifetime` needs store-side and in-app verification.
- Firebase API keys should be restricted in Firebase/Google Cloud Console even if they are expected to be present in client apps.

## D) Critical blockers

1. Release signing falls back to debug signing in `android/app/build.gradle` when `key.properties` is missing.
2. No local release keystore or key properties file was found under `android/` or `android/app/`.
3. The app cannot be considered ready for upload until a signed release `.aab` is generated and tested.
4. Privacy copy says data is local-only, but Firebase Analytics, Crashlytics, Auth, Firestore, and Google Sign-In are present.
5. Data safety declarations are required and must include app data handling plus SDK behavior.
6. Account deletion requirements likely apply because users can sign in/create an app account through Google Sign-In.
7. Cloud backup can upload financial records, but restore and deletion handling are incomplete.
8. Premium purchase flow includes a test unlock fallback.
9. `android.suppressUnsupportedCompileSdk=36` indicates the current Android Gradle/Flutter toolchain may need build verification with compile SDK 36.
10. Existing tests appear stale and do not prove release stability.

## E) Medium-risk issues

- `android/app/src/main/AndroidManifest.xml` declares biometric permissions directly, while other permissions are likely merged from plugins. Release merged manifest must be reviewed before Play declaration.
- Likely merged permissions include internet/network, billing, notifications, boot/wake, and foreground service behavior from dependencies.
- App label is `$imple`, which may be intentional branding but should be confirmed for Play listing consistency.
- `pubspec.yaml` description is still generic.
- Firebase Crashlytics/Analytics may collect diagnostics and usage data even if financial data stays local unless explicitly configured otherwise.
- `cloud_firestore` stores user financial backup data when cloud backup is used.
- `file_picker`, local export/import, and share behavior should be documented in privacy/Data safety if user data leaves app storage.
- Exact notification scheduling may require user-visible permission/justification depending on final Android behavior and plugin manifest output.

## F) Nice-to-have polish

- Derive Android `versionCode` and `versionName` from Flutter version to reduce manual mismatch risk.
- Add a short in-app privacy summary before Google sign-in and cloud backup.
- Add a clean "Delete cloud backup/account data" option in Settings if cloud backup ships.
- Add a Play listing checklist for app name, short description, full description, screenshots, category, support email, privacy URL, and content rating.
- Keep first release local-first if cloud restore cannot be completed safely.

## G) Exact files that will need edits later

- `android/app/build.gradle`
- `android/gradle.properties`
- `android/app/src/main/AndroidManifest.xml`
- `pubspec.yaml`
- `lib/features/settings/screens/privacy_policy_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/settings/screens/premium_screen.dart`
- `lib/services/purchase_service.dart`
- `lib/services/notification_service.dart`
- `lib/firebase_options.dart`

## H) Recommended order of execution

1. Decide whether cloud backup and Google sign-in ship in the first Play release.
2. If they ship, implement account deletion and cloud data deletion, then update privacy/Data safety.
3. If they do not ship, hide the auth/cloud backup entry points and remove misleading partial flows from release UX.
4. Remove premium test unlock behavior and verify Play product availability.
5. Configure release signing with a real upload key and Play App Signing plan.
6. Generate a signed release `.aab`.
7. Inspect the release merged manifest and map every permission to actual app behavior.
8. Run analysis, tests, and a release smoke test on a low-end Android device/emulator.
9. Prepare Play Console declarations: Data safety, privacy policy URL, account deletion URL, content rating, app access, financial features, and store listing.
10. Submit an internal test release before production.

## I) Estimated release readiness from 0 to 100

38/100.

The app has the right Android foundation, but the current release process and policy alignment are not ready for Google Play.

## J) Safe next action

Make a release decision for cloud/auth. The safest path is either complete cloud backup/account deletion/privacy accurately, or hide cloud/auth for the first release and ship a polished local-first expense tracker.
