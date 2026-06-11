# Release Blockers Checklist

Audit date: 2026-05-11

## Critical blockers

- [ ] Remove premium test unlock fallback from `lib/features/settings/screens/premium_screen.dart`.
- [ ] Verify `PurchaseService` only unlocks premium after a valid Play purchase flow.
- [ ] Update privacy policy screen and external privacy policy to match Firebase, Google sign-in, analytics, crash reporting, billing, notifications, and cloud backup behavior.
- [ ] Prepare accurate Google Play Data safety declarations.
- [ ] Add account deletion and cloud data deletion if Google sign-in remains enabled.
- [ ] Finish or hide cloud restore before release.
- [ ] Add explicit user consent/wording for backing up financial and vault data to Firestore.
- [ ] Configure real release signing; do not allow debug signing for release uploads.
- [ ] Generate and test a signed release `.aab`.
- [ ] Fix transaction type consistency between model defaults and database aggregate logic.

## Android and Play Store blockers

- [ ] Review release merged manifest permissions after building the release bundle.
- [ ] Verify notification permission behavior on Android 13+.
- [ ] Confirm exact alarm/idle scheduling is necessary or reduce reminder behavior.
- [ ] Confirm target SDK behavior on Android 15/16 with compileSdk/targetSdk 36.
- [ ] Remove or justify `android.suppressUnsupportedCompileSdk=36` after build verification.
- [ ] Confirm package identity and Play listing name are final.
- [ ] Restrict Firebase/API keys in Google Cloud/Firebase Console.
- [ ] Verify no debug/test data is bundled into release.
- [ ] Verify no generated build artifacts are treated as source release assets.

## Product blockers

- [ ] Fix stale tests or replace them with useful smoke tests.
- [ ] Add validation tests for add income, add expense, edit, delete, balance, category summary, and debt totals.
- [ ] Add loading/error states for backup, restore, auth, import, and export.
- [ ] Remove visible demo/testing controls from Settings.
- [ ] Clean hardcoded and mixed-language strings in auth, backup, notifications, and settings.
- [ ] Verify startup path with no PIN, PIN enabled, biometric enabled, Firebase failure, and offline mode.
- [ ] Verify low-end Android cold start and transaction list performance.

## Current readiness

Estimated release readiness: 38/100.

Safe next action: remove release-risk test behavior and decide whether cloud/auth ships in the first release.
