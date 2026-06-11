# Play Console Answers Draft

Draft date: 2026-05-14

Scope: draft Play Data Safety posture finalized against the signed release AAB at `build/app/outputs/bundle/release/app-release.aab`. Firebase Crashlytics and Google Play Billing are present. Firebase Analytics, Firebase Auth, Cloud Firestore, and Google Sign-In remain absent. This is a draft checklist, not a submitted Play Console form.

References:
- Google Play Data safety form guidance: https://support.google.com/googleplay/android-developer/answer/10787469
- Firebase Android Data Safety guidance: https://firebase.google.com/docs/android/play-data-disclosure

## Artifact Assumptions

- Package: `com.migueld.gastossimple`.
- Version: `1.1.0` / version code `3`.
- Signed AAB inspected: `build/app/outputs/bundle/release/app-release.aab`.
- Final app label in release manifest: `$imple`.
- minSdk: `24`.
- targetSdk: `36`.
- Local-only first release.
- No app account creation or sign-in.
- No Firebase Analytics.
- No Firebase Auth.
- No Cloud Firestore.
- No Google Sign-In.
- Firebase Crashlytics is active.
- Google Play Billing is active for one-time product `simple_pro_lifetime`.
- Local backup/export/import is active.
- PIN/vault PIN/biometric unlock is active.
- Daily local notifications are active unless disabled by preference.

## Final Signed AAB Inspection Update

Release artifact inspection status: complete.

Confirmed included in the signed AAB:
- Firebase Core.
- Firebase Crashlytics.
- Firebase Sessions / Installations / DataTransport support required by Crashlytics.
- Google Play Billing `7.1.1`.
- Local auth / biometric support.
- Flutter local notifications support.
- Share/file picker support for user-initiated backup export/import.
- URL launcher support for opening the hosted privacy policy.
- Home widget / quick-entry deep link support.

Confirmed absent from the signed AAB checks:
- Firebase Auth.
- Cloud Firestore.
- Google Sign-In.
- Firebase Analytics app SDK.

Final release permissions found:
- `android.permission.USE_BIOMETRIC`
- `android.permission.USE_FINGERPRINT`
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS`
- `com.android.vending.BILLING`
- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`
- `android.permission.WAKE_LOCK`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.FOREGROUND_SERVICE`
- `com.migueld.gastossimple.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

Nuance:
- `firebase-measurement-connector` appears as a transitive Firebase support library, but `firebase_analytics` / `firebase-analytics` is absent and no Firebase Analytics app SDK, Analytics manifest service/receiver, or `FirebaseAnalytics` class evidence was found.
- `play-services-location` and `play-services-places-placereport` appear transitively, but no location permission is declared in the final release manifest.

## Top-Level Data Safety Answers

Does the app collect or share user data?
- Draft answer: Yes.
- Reason: Crashlytics collects diagnostics off-device; Google Play Billing handles purchase data; local backup export can share data with another app by explicit user action.

Is all user data collected by the app encrypted in transit?
- Draft answer: Yes for Firebase/Google SDK network transmissions.
- Caveat: user-exported backup files are controlled by the user's chosen share/storage destination after export.

Can users request that data be deleted?
- Draft answer: No app account is provided. Users can delete local records, clear app data, or uninstall. Crashlytics data deletion is not exposed through an app account flow.
- Manual check: confirm Play Console wording for apps without accounts and with Crashlytics-only diagnostics.

Independent security review?
- Draft answer: No, unless a formal review has been completed outside this repository.

## Data Types To Disclose

### App info and performance

Crash logs:
- Draft answer: Collected.
- Shared: Yes, with Firebase/Google as the crash reporting service provider.
- Purpose: App functionality, crash reporting, diagnostics, reliability.
- Required/optional: Required while Crashlytics automatic collection remains enabled.
- Notes: Crashlytics fatal Flutter/platform handlers and nonfatal `recordError` are active.

Diagnostics:
- Draft answer: Collected.
- Shared: Yes, with Firebase/Google.
- Purpose: App functionality, diagnostics, reliability.
- Required/optional: Required while Crashlytics automatic collection remains enabled.

### Device or other IDs

Device or other IDs:
- Draft answer: Collected.
- Shared: Yes, with Firebase/Google.
- Purpose: Crash reporting, diagnostics, measuring crash impact.
- Required/optional: Required while Crashlytics automatic collection remains enabled.
- Notes: Firebase guidance for Crashlytics identifies Crashlytics installation UUID and transitive Firebase Installations/Sessions data.

### Financial info

Purchase history:
- Draft answer: Likely collected/processed.
- Shared: Likely shared/processed with Google Play Billing.
- Purpose: App functionality, purchase entitlement, fraud prevention, security, compliance.
- Required/optional: Optional in the sense that only users who purchase PRO use it, but required to complete PRO purchase.
- Manual check: confirm exact Play Console categories for Google Play Billing before submission.

Payment info:
- Draft answer: Do not mark as collected by the app unless Play Console/Billing guidance requires it.
- Notes: Payment method details are handled by Google Play, not by app code inspected in this pass.

User financial records:
- Draft answer: Not collected by developer servers in the current local-only release.
- Notes: Income, expenses, debts, goals, budgets, and vault transactions are stored locally. They can be exported by the user to a JSON backup and shared through Android share targets.
- Manual check: confirm whether user-initiated backup export to another app must be declared as sharing in the Data Safety form.

### Files and docs

Files and docs:
- Draft answer: Possibly shared by user action.
- Purpose: App functionality, backup/export/import.
- Required/optional: Optional/user-initiated.
- Notes: Backup export creates `gastos_simple_backup.json`; import reads a user-selected JSON file through the Android file picker.
- Manual check: determine whether to classify this as Files/docs, Financial info, or both in the Play Console UI.

## Data Types Not Expected To Be Disclosed

Do not disclose as collected unless final release behavior changes:
- Location.
- Contacts.
- Photos and videos.
- Audio files.
- Calendar.
- Health and fitness.
- Messages.
- Personal info such as name, email address, phone number, address, race/ethnicity, political/religious beliefs, sexual orientation, or other profile information.
- Web browsing.
- Firebase Analytics app interactions/events.
- Account credentials or account identifiers for app sign-in.
- Firestore/cloud backup data.

## Permissions And SDK Notes

Final permissions from signed release AAB inspection:
- `INTERNET`: Crashlytics/Firebase, Billing, external privacy URL/network behavior.
- `ACCESS_NETWORK_STATE`: Google/Firebase/Billing SDK support.
- `com.android.vending.BILLING`: one-time PRO purchase.
- `POST_NOTIFICATIONS`: daily reminders on supported Android versions.
- `VIBRATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`: notification scheduling/plugin behavior.
- `USE_BIOMETRIC`, `USE_FINGERPRINT`: local biometric unlock.

Release check:
- Completed against the signed AAB in `.codex/reports/signed_aab_artifact_inspection.md`.

## Privacy Policy Must Say

- Financial records are stored locally on the user's device.
- No app account is required or offered in the first local-only release.
- No cloud backup or cloud sync is offered in the first local-only release.
- Users can manually export/import a JSON backup; exported files may contain financial and vault data and are controlled by the selected destination after sharing/saving.
- Firebase Crashlytics is used for crash diagnostics and may collect crash logs, stack traces, relevant app state, device metadata, and installation/session identifiers.
- Google Play Billing is used for the one-time PRO purchase and purchase/entitlement state.
- PIN/vault PIN are stored locally through secure storage.
- Biometric authentication is handled by the device OS; biometric templates are not received by the app.
- Local notifications/reminders may be scheduled and may require notification permission.
- The app does not use Firebase Analytics, Firebase Auth, Firestore, or Google Sign-In in the current first release.

## Reviewer Notes Draft

$imple is a local-first personal finance app. In the first release, financial records are stored locally on the device and are not uploaded to a developer cloud service. The app does not offer account creation, sign-in, cloud backup, or cloud restore. Users may manually export/import a JSON backup using Android share/file-picker flows; exported files are controlled by the user and may contain financial records. Firebase Crashlytics is used only for crash diagnostics. Google Play Billing is used for the one-time PRO purchase `simple_pro_lifetime`. Firebase Analytics, Firebase Auth, Cloud Firestore, and Google Sign-In are not included in the current artifact.

## Manual Verification Before Submission

- Confirm hosted privacy policy content remains public at `https://simple-app-ar.github.io/privacy.html`.
- Confirm final release AAB dependencies and manifest still match this draft if a new AAB is generated.
- Confirm Play Billing product `simple_pro_lifetime` exists and works in internal testing.
- Confirm Crashlytics is the only Firebase product SDK beyond Firebase Core.
- Confirm Analytics/Auth/Firestore/Google Sign-In remain absent.
- Confirm notification permission and reminder behavior on Android 13+.
- Confirm Play Console category choices for Billing and user-initiated backup sharing.
