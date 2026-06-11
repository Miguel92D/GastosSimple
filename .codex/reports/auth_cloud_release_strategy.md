# Auth / Cloud Release Strategy

Audit date: 2026-05-11

Scope: decision-only review. No app source files were modified.

## 1. Executive summary

Recommended first-release strategy: **B. Hide/disable auth/cloud for first release and ship local-only.**

The current app has a real local-first expense tracker foundation, while the auth/cloud chain is incomplete and policy-sensitive. Keeping auth/cloud for the first release would force several high-risk tasks before shipping: account deletion, cloud data deletion, accurate privacy policy, Play Data safety declarations, user consent for financial/vault cloud upload, and reliable restore.

The safest first release is a clean local-only app with local backup/import/export, PIN/biometric protection, and no visible Google account or cloud backup flow. The existing auth/cloud work can be preserved for a later release branch or checkpoint, but it should not be exposed in the first Play release.

## 2. What the auth/cloud chain currently does

Auth flow:

- `lib/services/auth_service.dart` defines a Firebase Auth + Google Sign-In service.
- `lib/features/auth/screens/auth_screen.dart` provides sign-in/sign-out UI.
- `lib/core/router/app_router.dart` imports `AuthScreen` and exposes `/auth`.
- `lib/core/router/app_routes.dart` adds an `auth` route constant.
- `lib/main.dart` registers `AuthService.instance` in the app provider tree.

Account creation/sign-in:

- Google Sign-In can create/sign in a Firebase Auth user.
- The UI supports sign-in and sign-out.
- There is no account deletion method.
- There is no cloud data deletion method.
- There is no account deletion route or settings action.

Cloud backup:

- `lib/features/settings/screens/backup_screen.dart` imports `AuthService` and `CloudBackupService`.
- Backup screen shows a cloud button:
  - signed out: "Iniciar sesion con Google"
  - signed in: "Crear backup en la nube"
- `CloudBackupService.fullBackup()` uploads all normal transactions and vault transactions to Firestore under `users/{uid}`.
- `CloudBackupService.tryAutoBackup()` uploads today's transactions when a Firebase user exists.

Cloud restore:

- `CloudBackupService.restoreBackup()` only checks whether a user doc exists and logs a message.
- It does not restore transactions into SQLite.
- The visible restore button in `BackupScreen` is still local file restore through `BackupController`, not a complete cloud restore.

Settings/startup dependencies:

- `SettingsScreen` watches `AuthService` and exposes "Cuenta Google".
- `BackupScreen` watches `AuthService`.
- `main.dart` registers `AuthService`, so keeping the dirty chain makes auth part of app runtime.
- `firebase_options.dart` adds iOS Firebase options, but this is review-only and not required for the Android first-release decision.

## 3. Risks of keeping it for first release

Option A risk: high.

- Privacy policy currently says data is local-only and not uploaded, which is false if cloud backup ships.
- Play Data safety declarations must cover Auth, Google Sign-In, Firestore financial backup data, Analytics, Crashlytics, billing, notifications, and local export/share behavior.
- Account deletion requirements likely apply because users can create/sign in to an account.
- Cloud data deletion is missing.
- Cloud restore is incomplete, so users may trust a backup they cannot restore from.
- Full backup includes vault transactions, which needs explicit consent and clear wording.
- Settings/navigation would expose a partially finished account feature.
- Auth provider wiring adds startup/runtime surface before the core app is stable.
- Hardcoded/mixed-language auth and backup strings reduce release polish.

Option A should only be chosen if first release is delayed until auth/cloud is fully completed and validated.

## 4. Risks of hiding/disabling it

Option B risk: low to medium.

- Some code may remain in the repository if the work is hidden rather than reverted, so the release diff must be checked carefully.
- Firebase dependencies may still affect Data safety if Analytics/Crashlytics remain enabled, even without auth/cloud UI.
- Hidden code can drift if not documented.
- Local backup copy must be clear so users do not expect cloud sync.

These risks are manageable because the first release can still be honest: local storage, local backup, optional device security, and no account/cloud feature exposed to users.

## 5. Risks of reverting it

Option C risk: low for first release, medium for developer workflow.

- Reverting the auth/cloud dirty changes would likely produce the cleanest local-only baseline.
- It avoids exposing incomplete account/cloud flows.
- It reduces Play policy surface.
- It may discard useful work unless it is saved in a branch/patch/checkpoint first.
- Because current auth/cloud files are uncommitted and intertwined across router/settings/backup/main/service files, reverting without preserving work could lose implementation context.

Option C is a good mechanical cleanup tactic if the user is comfortable discarding or separately saving the current auth/cloud work. As a product strategy, it is equivalent to local-only first release.

## 6. Recommended strategy for first release

Choose **B. Hide/disable auth/cloud for first release and ship local-only.**

This is the safest product strategy because it keeps the first release small, truthful, and shippable while preserving the option to finish auth/cloud later.

Implementation later should hide all user-facing auth/cloud entry points and prevent cloud uploads from release behavior. The first release should keep:

- local transaction tracking
- local dashboard/history
- local backup/export/import
- PIN/biometric protection
- clear local-only privacy wording

Auth/cloud should move to a later release only after:

- real cloud restore exists
- account deletion exists
- Firestore data deletion exists
- privacy policy is rewritten
- Play Data safety answers are prepared
- vault backup consent is explicit
- auth/backup copy is localized and clear

## 7. Exact files that would need to change later if we apply that strategy

Likely files to hide/disable auth/cloud for first release:

- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/main.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`
- `lib/core/i18n/app_translations.dart`

Files to review but not necessarily change for this strategy:

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `lib/features/settings/screens/privacy_policy_screen.dart`
- `lib/services/transaction_service.dart`
- `pubspec.yaml`
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`

## 8. Why this is the safest path

- It avoids shipping an incomplete cloud restore story.
- It avoids triggering account deletion requirements through a visible account feature in the first release.
- It makes privacy copy easier to make accurate.
- It reduces Play Data safety complexity.
- It protects users from assuming financial/vault data is recoverable from cloud when restore is not implemented.
- It preserves the core value of the app: simple, local expense tracking.
- It reduces startup/routing complexity before release validation.
- It keeps later auth/cloud work possible without blocking the first release.

## 9. Exact safe next action

Do not code yet.

Next pass should apply Strategy B with minimal source changes:

1. Remove or hide visible Google account entry points from Settings and Backup.
2. Remove `/auth` route exposure and `AuthService` provider wiring from release path.
3. Prevent cloud backup calls from being reachable in release UI.
4. Leave existing local backup/import/export intact.
5. Update the cleanup reports after the source cleanup.

After that, continue with the currency/calculation chain decision before release fixes begin.
