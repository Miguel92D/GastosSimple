# Strategy B Applied

Audit date: 2026-05-11

Strategy: hide/disable auth and cloud entry points for first release so the app ships local-only while preserving local backup.

## 1. Executive summary

Strategy B has been applied with minimal source changes. The first-release UX no longer exposes Google sign-in, Google account settings, `/auth` routing, cloud backup buttons, or automatic cloud upload after transaction changes.

Local backup/export/import remains available through the existing Backup screen.

Auth/cloud code was not deleted. It remains in the repository for a later release, but it is no longer reachable from normal release navigation.

## 2. Files modified

- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/main.dart`
- `lib/features/transactions/controllers/transaction_controller.dart`
- `.codex/reports/strategy_b_applied.md`
- `.codex/checklists/local_only_release_behavior_checklist.md`

## 3. What was hidden/disabled

- Removed `/auth` route handling from `AppRouter`.
- Removed `AppRoutes.auth`.
- Removed `AuthService` provider registration from app startup.
- Removed the Google account entry from Settings.
- Removed Google sign-in and cloud backup actions from Backup screen.
- Removed `AuthService` and `CloudBackupService` imports from Backup screen.
- Removed the hidden `CloudBackupService.tryAutoBackup()` calls after add/update/delete transaction operations.

## 4. What was intentionally left in code but not exposed

- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `google_auth_error` translation keys in translation files

These were left untouched because deleting unfinished auth/cloud work was not required to apply Strategy B. They should be revisited only when auth/cloud is intentionally resumed.

## 5. Startup/routing impact

- App startup no longer registers `AuthService`.
- Normal app startup no longer depends on Firebase Auth or Google Sign-In state listeners.
- `/auth` is no longer registered in the app router.
- No normal Settings or Backup action navigates to auth.
- Firebase initialization, Analytics, and Crashlytics remain unchanged because they are outside this Strategy B cleanup scope.

## 6. User-visible behavior after this pass

- Users can still use the app locally.
- Users can still open Settings.
- Users can still open Backup.
- Backup screen offers local export and local restore only.
- Users no longer see Google account, Google sign-in, or cloud backup controls.
- Transaction changes no longer trigger automatic cloud backup.

## 7. Remaining auth/cloud risks, if any

- Auth/cloud source files still exist and are untracked/dirty, but are not exposed from normal release navigation.
- Firebase Auth, Google Sign-In, and Firestore dependencies may still exist in `pubspec.yaml`; dependency and Play Data safety implications still need a release pass.
- `CloudBackupService` still contains incomplete restore/delete behavior, but no active app path calls it after this pass.
- Privacy policy still needs a final release review because Firebase Analytics/Crashlytics remain initialized.

## 8. Exact next safe action

Run a focused verification pass:

1. Confirm `rg "AuthService|CloudBackupService|/auth"` only finds unexposed auth/cloud files and no normal release navigation.
2. Decide the currency/calculation chain strategy.
3. Then run `flutter analyze` after the currency/calculation chain is resolved, because that chain still has mixed staged/unstaged financial input changes.
