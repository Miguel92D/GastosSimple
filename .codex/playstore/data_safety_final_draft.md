# Data Safety final draft

## 1. Confirmed data handled locally

The signed AAB supports a local-first personal finance app. These data types are handled locally by normal app operation:

- Expenses, income, debts, goals, budgets, categories, notes, dates, and amounts.
- Vault/secure financial records where used.
- Currency/language/settings preferences.
- Local PRO entitlement state.
- PIN/vault PIN/security settings through local secure storage.
- Local notification reminder settings.
- Local SQLite/shared-preference app state.

Draft Play Console posture:

- Do not mark user financial records as developer server collection for this release.
- Explain that financial records are stored locally and are not uploaded to a developer cloud service.

## 2. Confirmed off-device data / SDK diagnostics

The signed AAB includes:

- Firebase Core.
- Firebase Crashlytics.
- Firebase Sessions.
- Firebase Installations.
- Firebase DataTransport.

Draft Play Console posture:

- App collects user data: yes.
- Data types include crash logs, diagnostics, and device or other IDs as applicable to Crashlytics/Firebase installation/session identifiers.
- Purpose: app functionality, crash reporting, diagnostics, reliability.
- Required/optional: treat as required while automatic Crashlytics collection remains enabled.
- Shared: yes with Firebase/Google as service provider, if Play Console asks whether data is shared.

## 3. Billing-related disclosures

The signed AAB includes:

- `com.android.vending.BILLING`
- Google Play Billing `7.1.1`
- Product ID expected by app code: `simple_pro_lifetime`

Draft Play Console posture:

- Disclose Google Play Billing for optional one-time PRO purchase.
- Likely data type: `Financial info > Purchase history`.
- Purpose: app functionality, purchase entitlement, fraud prevention/security/compliance where applicable.
- Required/optional: optional for users who do not buy PRO, required to complete PRO purchase.

Manual confirmation:

- Confirm exact Play Console wording for Google Play Billing.
- Do not mark payment method details as collected by app code unless Play Console explicitly requires it for Google Play Billing.

## 4. Crashlytics-related disclosures

Disclose:

- Crash logs.
- Diagnostics.
- Relevant app/device metadata.
- Installation/session identifiers.
- Stack traces and app state relevant to crashes.

Purpose:

- App functionality.
- Crash reporting.
- Diagnostics.
- Reliability.

Do not disclose:

- Firebase Analytics app activity/events.
- Advertising tracking.

Manual confirmation:

- Confirm whether Play Console marks these as collected and shared with Firebase/Google under service provider handling.

## 5. Backup/export/import treatment

The signed AAB includes:

- `share_plus` file provider.
- `file_picker` query for `GET_CONTENT */*`.

App behavior:

- User can export/import a local backup JSON.
- Exported backup files may contain financial and vault records.
- Export/share destination is selected by the user.

Draft Play Console posture:

- Treat backup export/import as user-initiated.
- Consider `Files and docs`, `Financial info`, or both depending on Play Console wording.
- If Play Console treats on-device transfer to another app as sharing, mark this as shared by user action.

Manual confirmation:

- Choose the exact category in the Play Console UI.

## 6. Biometrics/local auth treatment

The signed AAB includes:

- `USE_BIOMETRIC`
- `USE_FINGERPRINT`
- local auth / AndroidX biometric support

Draft Play Console posture:

- Biometric authentication is handled by the device OS.
- The app does not receive or store biometric templates.
- Local PIN/vault PIN/security settings are stored locally through secure storage.

Manual confirmation:

- Confirm whether Play Console asks about biometric/security data separately. Do not imply biometric templates are collected by the developer.

## 7. Notifications treatment

The signed AAB includes:

- `POST_NOTIFICATIONS`
- `VIBRATE`
- `WAKE_LOCK`
- `RECEIVE_BOOT_COMPLETED`
- `FOREGROUND_SERVICE`

Draft Play Console posture:

- Local reminders/notifications may be scheduled if enabled.
- Android 13+ may request notification permission.
- Notification behavior is app functionality, not analytics/tracking.

Manual confirmation:

- Test Android 13+ notification permission prompt on internal track.

## 8. What to answer carefully in Play Console

Top-level:

- Does the app collect/share user data? yes.
- Is collected user data encrypted in transit? yes for Firebase/Google SDK transmissions.
- Account deletion? no app account is offered; users can delete local records, clear app data, or uninstall.
- Independent security review? no unless completed externally.

Select/disclose carefully:

- App info and performance: crash logs and diagnostics.
- Device or other IDs: Crashlytics/Firebase installation/session identifiers.
- Financial info: purchase history for Google Play Billing.
- Files and docs and/or Financial info: user-initiated backup export/import if Play Console requires it.

Do not select unless behavior changes:

- Location.
- Contacts.
- Photos/videos/audio.
- Calendar.
- Health and fitness.
- Messages.
- Personal info such as name, email, phone, address, demographics.
- Firebase Analytics/app activity analytics.
- Firebase Auth/account data.
- Firestore/cloud backup.
- Google Sign-In.
- Developer server upload of financial records.

## 9. Manual verification items

- Confirm privacy policy URL in Play Console: `https://simple-app-ar.github.io/privacy.html`.
- Confirm hosted privacy policy is public and matches this release posture.
- Confirm `simple_pro_lifetime` is created, priced, active, and visible to internal testers.
- Confirm exact Billing data category in Play Console.
- Confirm exact backup export/share category in Play Console.
- Confirm Crashlytics collected/shared/service-provider answers.
- Confirm Android 13+ notification permission behavior.
- Run internal testing billing checklist before wider rollout.
