# Privacy And Data Safety Notes

Date: 2026-05-14

Purpose: operational notes for aligning `$imple` privacy policy, Play Data Safety, and reviewer messaging for the current local-only release artifact.

## Current Posture

The app is local-first for financial records. It does not currently expose account creation, Google sign-in, cloud backup, or cloud restore in the normal Settings/Backup flow. Auth/cloud SDKs and Firebase Analytics are absent from the signed release AAB inspection.

The app is not "offline only" or "no data collected" because Firebase Crashlytics and Google Play Billing are active. Local backup export also allows user financial data to leave the app through Android share targets by explicit user action.

Signed AAB inspected:
- `build/app/outputs/bundle/release/app-release.aab`
- Package: `com.migueld.gastossimple`
- Version: `1.1.0` / `3`
- App label: `$imple`
- minSdk: `24`
- targetSdk: `36`

Confirmed included from the signed artifact:
- Firebase Core.
- Firebase Crashlytics.
- Firebase Sessions / Installations / DataTransport support.
- Google Play Billing `7.1.1`.
- Local auth / biometric support.
- Notifications support.
- Share/file picker support.
- URL launcher support.
- Home widget / quick-entry deep link support.

Confirmed absent from the signed artifact:
- Firebase Auth.
- Cloud Firestore.
- Google Sign-In.
- Firebase Analytics app SDK.

Final release permissions found:
- `USE_BIOMETRIC`
- `USE_FINGERPRINT`
- `VIBRATE`
- `POST_NOTIFICATIONS`
- `com.android.vending.BILLING`
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `WAKE_LOCK`
- `RECEIVE_BOOT_COMPLETED`
- `FOREGROUND_SERVICE`

## Confirmed Disclosures

Include these in the privacy policy and Play Data Safety posture:
- Local financial data storage for expenses, income, debts, goals, budgets, and vault transactions.
- User-controlled local backup export/import, including that backup JSON can contain financial and vault records.
- Firebase Crashlytics crash diagnostics sent to Firebase/Google.
- Crashlytics-related crash logs, stack traces, relevant app state, device metadata, and installation/session identifiers.
- Google Play Billing for the one-time PRO purchase.
- Local PIN/vault PIN storage through secure storage.
- Biometric unlock handled by the device OS, with no biometric templates received by the app.
- Local notification reminders and notification permission behavior.
- External browser opening for the hosted privacy policy.

## Likely Disclosures

Confirm exact Play Console categories before submission:
- `App info and performance`: crash logs and diagnostics.
- `Device or other IDs`: Crashlytics/Firebase installation/session identifiers.
- `Financial info > Purchase history`: Google Play Billing purchase/restore/entitlement handling.
- `Files and docs` and/or `Financial info`: user-initiated backup JSON export/import if Play Console treats on-device transfer to another app as sharing.

Final artifact nuance:
- `firebase-measurement-connector` is present transitively, but Firebase Analytics is not included.
- `play-services-location` is present transitively, but no Android location permission is declared.

## Items Not To Claim

Do not claim these for the current release unless the artifact changes:
- Firebase Analytics usage tracking.
- Firebase Auth accounts.
- Firestore/cloud backup.
- Google Sign-In.
- Developer server upload of financial records.
- App account deletion flow.
- Collection of name/email/phone/location/contacts/photos/audio/calendar/health/messages.

## Privacy Policy Wording Requirements

Replace broad claims like:
- "We do not upload your information to external servers."
- "The app does not share any personal or financial data with third parties."
- "No data is shared."

Use narrower accurate wording:
- "Your financial records are stored locally on your device and are not uploaded to our cloud servers in this release."
- "You can manually export or import a backup file. Exported backup files may contain your financial records and are controlled by the destination you choose."
- "We use Firebase Crashlytics to diagnose crashes and improve app stability. Crashlytics may send crash logs, stack traces, app state, device metadata, and installation identifiers to Firebase/Google."
- "Google Play Billing is used to process the optional one-time PRO purchase."
- "Biometric authentication is handled by your device operating system; the app does not receive or store biometric templates."
- "The app may schedule local reminders if notifications are enabled."

## Reviewer Notes

Recommended reviewer note:

`$imple is a local-first expense app. The first release stores financial records locally and does not provide account creation, sign-in, cloud backup, or cloud restore. Users can manually export/import a JSON backup and choose where to share or store it. Firebase Crashlytics is used only for crash diagnostics, and Google Play Billing is used for the optional one-time PRO purchase. Firebase Analytics, Firebase Auth, Cloud Firestore, and Google Sign-In are not included in the current release artifact.`

## Manual Verification Checklist

- Verify the hosted URL is public, readable without login, and matches the Play listing.
- Signed release AAB generated and inspected.
- Release merged manifest and dependency metadata inspected.
- No Analytics/Auth/Firestore/Google Sign-In SDKs appeared in the signed release artifact checks.
- Crashlytics is present and disclosed.
- Billing permission/product behavior is disclosed.
- Confirm `simple_pro_lifetime` is configured in Play Console and tested on an internal track.
- Confirm notification runtime permission behavior on Android 13+.
- Confirm Play Console choices for Billing purchase history and user-initiated backup sharing.

## Exact Safest Next Action

Finalize the Play Console Data Safety form from the signed AAB inspection, upload `build/app/outputs/bundle/release/app-release.aab` to an internal testing track, and run the billing/purchase/restore smoke test for `simple_pro_lifetime`.
