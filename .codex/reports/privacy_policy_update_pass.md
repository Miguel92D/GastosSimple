# Privacy Policy Update Pass

Pass date: 2026-05-13

Scope: privacy-policy content alignment for the current local-only release artifact. No billing logic, release signing config, AAB generation, Android release config, or broad refactors were performed.

## 1. Executive summary

The in-app privacy policy and hosted privacy policy text were updated to match the current release posture:

- local-only financial records;
- no Firebase Auth, Firestore, Google Sign-In, or Firebase Analytics;
- Firebase Crashlytics included for crash diagnostics;
- Google Play Billing used for the one-time PRO purchase;
- local backup/export/import files controlled by the user;
- local PIN/vault PIN, biometrics, and notifications disclosed.

The old broad claims that the app never uploads information to external servers and never shares data with third parties were removed from the active policy content because they were too broad for a build with Crashlytics and Google Play Billing.

## 2. Files modified

- `lib/features/settings/screens/privacy_policy_screen.dart`
- `lib/core/i18n/app_translations.dart`
- `docs/privacy.html`
- `SimpleLanding/privacy.html`
- `.codex/reports/privacy_policy_update_pass.md`

## 3. In-app privacy policy changes

Updated `PrivacyPolicyScreen` to disclose:

- financial data stored on-device, including income, expenses, debts, goals, budgets, categories, notes, and private vault movements;
- local JSON backup export/import and user control over shared/saved backup destinations;
- Google Play Billing for the one-time PRO purchase and restore state;
- Firebase Crashlytics crash diagnostics and the absence of Firebase Analytics;
- local PIN/vault PIN and biometric handling by the operating system;
- local notification reminders;
- no account, sign-in, Google Sign-In, Firebase Auth, Firestore, or cloud backup in this release.

Also updated the legacy `privacy_policy_part*` translation strings in `AppTranslations` so stale policy text does not remain in that app source content.

## 4. Hosted privacy policy changes

Updated `docs/privacy.html`, which matches the in-app hosted URL path `https://miguel92d.github.io/GastosSimple/privacy.html`.

Also updated the duplicate hosted/landing copy in `SimpleLanding/privacy.html` so it does not keep stale claims about optional Firebase authentication or anonymous analytics.

Hosted policy content now covers:

- on-device financial records;
- user-controlled backup export/import;
- Google Play Billing PRO purchase handling;
- Firebase Crashlytics diagnostics;
- local security and biometrics;
- notifications;
- no account/cloud sync/Auth/Firestore/Google Sign-In/Analytics for the current release.

## 5. Key disclosure points now covered

- Personal finance data stays on-device during normal app use.
- Exported/imported backup files may contain financial and vault data and are controlled by the user after sharing or saving.
- Google Play Billing handles the optional one-time PRO purchase.
- Crashlytics may send crash/error reports, stack traces, app state, device metadata, and installation identifiers to Firebase/Google.
- PIN/vault PIN are local security controls; biometric authentication is handled by the OS and biometric templates are not received by the app.
- Notifications may be scheduled locally and controlled through OS permissions.
- The current release does not offer accounts, sign-in, Firebase Auth, Firestore, Google Sign-In, Firebase Analytics, or cloud backup.

## 6. Remaining manual items, if any

- Publish the updated hosted `docs/privacy.html` content to the actual public URL and verify it is reachable without login.
- Confirm the Play Store listing privacy policy URL points to the updated hosted page.
- Re-run final Play Data Safety answers after the signed release AAB and release merged manifest are generated.
- `dart format` was attempted on the updated Dart policy files but timed out in this environment; the edits are content-only and should be formatted/verified in the normal release validation pass if needed.

## 7. Exact next safe action

Publish or deploy the updated hosted privacy policy page, verify the public URL, then proceed to signing/AAB preparation and final release-manifest/Data Safety verification from the signed artifact.
