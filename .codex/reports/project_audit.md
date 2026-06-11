# Project Audit

Audit date: 2026-05-11

Skills applied: expense-orchestrator, expense-architecture-auditor, expense-financial-logic, expense-ui-ux, expense-qa-bug-hunter, expense-release-finisher.

Policy references checked:
- Google Play target API level: https://developer.android.com/google/play/requirements/target-sdk
- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play account deletion: https://support.google.com/googleplay/android-developer/answer/13327111
- Android app signing: https://developer.android.com/studio/publish/app-signing
- Android App Bundle: https://developer.android.com/guide/app-bundle

## A) Executive summary

Gastos Simple is a Flutter app with a real local-first expense tracking core. It already has transaction entry, dashboard, history, settings, PIN/biometric protection, local backup, goals/debts/budgets areas, Firebase initialization, Google sign-in, cloud backup code, analytics, crash reporting, notifications, purchases, and multi-platform project scaffolding.

The app is not production-ready yet. The most important blockers are not a need to rebuild; they are a small set of release-critical mismatches: privacy copy says data is local-only while Firebase/Firestore/Google sign-in/analytics/crash reporting are present, cloud restore is incomplete, account deletion is missing, premium can be unlocked through a test fallback, release signing is not configured, and tests/builds were not proven in this audit pass.

Release readiness estimate: 38/100.

## B) What is already good

- The project is clearly a Flutter app with Android, iOS, web, macOS, Windows, and Linux folders.
- The Android package/applicationId is consistent across `android/app/build.gradle`, `android/app/src/main/AndroidManifest.xml`, and `android/app/google-services.json`: `com.migueld.gastossimple`.
- Core transaction storage exists in SQLite through `lib/database/database_helper.dart`.
- Main expense flows exist: quick entry, add/edit transaction, dashboard, history/movements, stats, settings.
- Firebase is initialized centrally in `lib/main.dart`.
- PIN and biometric security services exist and are wired into startup.
- Local backup/export/import is present.
- The app already disables the Flutter debug banner in `lib/main.dart`.
- Release build settings already enable minification and resource shrinking.
- The app is simple enough to finish with targeted changes.

## C) What is incomplete

- Cloud backup is partial. `CloudBackupService.restoreBackup()` does not restore data into local storage.
- Auth flow is present but minimal. There is Google sign-in/sign-out, but no user-facing account deletion or cloud data deletion flow.
- Privacy policy screen is inaccurate for the current app because it claims data is local-only and not uploaded to external servers.
- Premium purchase flow is not production-safe because `PremiumScreen` can unlock premium locally when the purchase product is unavailable.
- Recurring transactions are modeled but the add transaction screen has recurring state with no real user flow.
- Goal linkage fields exist in transactions but there is no clear add/edit UI for assigning a transaction to a goal.
- Notification permission and exact alarm behavior need a release pass for Android 13+ and recent Android versions.
- Test coverage appears stale. `test/widget_test.dart` expects text that may no longer match the current app, and Firebase initialization may make widget tests fail without mocks.
- Some localization is incomplete or inconsistent, with hardcoded strings in auth/backup/settings and mojibake in notification text.
- Several feature folders are empty or appear half-started.

## D) Critical blockers

1. Privacy policy mismatch: `lib/features/settings/screens/privacy_policy_screen.dart` says no data is uploaded, but Firebase Analytics, Crashlytics, Auth, Firestore, Google Sign-In, and cloud backup are present.
2. Missing account deletion path: Google sign-in/account creation is available, so Play account deletion requirements likely apply.
3. Cloud restore is not implemented even though cloud backup UI exists.
4. Premium has a test unlock fallback in `lib/features/settings/screens/premium_screen.dart`.
5. Release signing is not ready. No `android/key.properties`, `android/app/key.properties`, `.jks`, or `.keystore` was found, and release signing falls back to debug signing.
6. Release build/App Bundle was not verified in this pass.
7. Data safety declarations must be prepared for Firebase, Google sign-in, crash reporting, analytics, billing, notifications, and optional cloud backup.
8. Financial type naming is inconsistent: `Transaction.fromMap()` defaults to `expense`, while database aggregate methods expect `gasto` and `ingreso`.
9. Tests appear stale and may not validate current app behavior.
10. Existing repository state was already dirty before this audit, including modified and untracked app files.

## E) Medium-risk issues

- `CloudBackupService.tryAutoBackup()` swallows errors, which can hide backup failures.
- Firestore upload includes normal transactions and vault transactions during full backup; vault cloud behavior needs explicit user consent.
- `TransactionRepository` and `TransactionController` use static patterns, which work now but can make testing and future auth/cloud separation harder.
- App startup performs several service initializations before the UI loads, increasing crash and cold-start risk on low-end devices.
- Notification scheduling uses exact idle behavior by default; this should be reviewed against actual reminder requirements.
- Settings contains visible demo/testing behavior.
- Some screens mix English and Spanish text.
- `pubspec.yaml` still has the default description: "A new Flutter project."
- iOS Firebase bundle ID differs from the Android package, which is not a Play blocker but indicates platform identity drift.
- Generated/build output appears present in the repo tree and should be kept out of release review.

## F) Nice-to-have polish

- Make empty states consistent across dashboard, movements, debts, budgets, goals, stats, backup, and auth.
- Use one calm financial tone for all settings, validation, and error messages.
- Add a clear offline-first explanation before optional Google sign-in/cloud backup.
- Add lightweight loading states to auth, backup, import/export, and restore actions.
- Improve accessibility labels on icon-heavy quick entry and dashboard actions.
- Keep release copy short and trustworthy, especially around sensitive money data.

## G) Exact files that will need edits later

- `lib/features/settings/screens/privacy_policy_screen.dart`
- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/premium_screen.dart`
- `lib/services/purchase_service.dart`
- `lib/features/transactions/models/transaction.dart`
- `lib/database/database_helper.dart`
- `lib/features/transactions/screens/add_transaction_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/services/notification_service.dart`
- `lib/main.dart`
- `test/widget_test.dart`
- `test/smoke_test.dart`
- `pubspec.yaml`
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/gradle.properties`

## H) Recommended order of execution

1. Freeze the scope for release: local expense tracking, optional Google sign-in/cloud backup, PIN/biometrics, and stable premium behavior only.
2. Remove or disable all test/demo premium behavior before any public build.
3. Decide cloud backup policy: either make cloud backup fully functional with restore and deletion, or hide it for the first release.
4. Fix privacy and Data safety alignment after the cloud decision.
5. Add account deletion/data deletion flow if Google sign-in remains enabled.
6. Fix financial type consistency and add targeted calculation checks.
7. Repair stale tests and add smoke coverage for launch, add expense, add income, edit/delete, backup disabled/enabled, and PIN gate.
8. Configure release signing with a real upload key and remove the debug signing fallback.
9. Run `flutter analyze`, `flutter test`, and `flutter build appbundle --release`.
10. Perform a final Play Console checklist pass.

## I) Estimated release readiness from 0 to 100

38/100.

The product has a usable foundation, but it is not ready for Google Play submission until release signing, privacy/Data safety, account deletion, test purchase behavior, and build verification are handled.

## J) Safe next action

Use `expense-release-finisher` first to remove release blockers that expose users or violate Play expectations: premium test unlock, privacy policy mismatch, account deletion requirement, and signing readiness plan. Then use `expense-financial-logic` for the transaction type/calculation consistency pass.
