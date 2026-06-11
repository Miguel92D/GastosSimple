# Privacy/Data Safety Final Alignment

Audit date: 2026-05-13

Scope: final privacy policy and Play Data Safety alignment pass for the current local-only release artifact after Firebase Crashlytics was reintroduced. This pass was documentation-only. No application source, business logic, Android release config, signing material, or AAB output was modified.

Policy references:
- Google Play Data safety form guidance: https://support.google.com/googleplay/android-developer/answer/10787469
- Firebase Android Data Safety guidance, including Crashlytics: https://firebase.google.com/docs/android/play-data-disclosure

## 1. Executive summary

The current artifact is still local-only for user financial records and account/cloud behavior. Normal Settings and Backup flows expose local settings, local backup/export/import, privacy policy, currency, local PIN/biometric security, and Premium billing. The dependency graph and static scans show Firebase Crashlytics and Firebase Core are present, while Firebase Analytics, Firebase Auth, Cloud Firestore, and Google Sign-In remain absent.

Privacy and Play Data Safety are not ready to submit as "no data collected/shared." Crashlytics now sends crash diagnostics and related app/device identifiers off-device to Firebase/Google. Google Play Billing is active for the one-time `simple_pro_lifetime` product. Local backup/export can transfer user financial data to another app through Android sharing by explicit user action. Notifications and biometrics/local security also require accurate privacy wording.

The in-app privacy text is only partially aligned. It correctly says financial records are stored locally, but it still broadly says no information is uploaded to external servers and no data is shared with third parties. That is no longer accurate with Crashlytics and Billing in the release posture. The privacy policy must be updated before signing/AAB submission.

## 2. Current artifact scope

Confirmed active or relevant:
- Local SQLite/shared-preference financial app data.
- Local backup export/import through `share_plus`, `file_picker`, and a JSON file named `gastos_simple_backup.json`.
- Google Play Billing through `in_app_purchase` for one-time PRO product `simple_pro_lifetime`.
- Firebase Core and Firebase Crashlytics.
- Local PIN, vault PIN, biometric unlock, and secure local storage.
- Local notifications for daily reminders.
- Home widget and `gastossimple://quick_entry` deep link.
- URL launcher for the hosted privacy policy.

Confirmed absent from current package/source scans:
- Firebase Analytics.
- Firebase Auth.
- Cloud Firestore.
- Google Sign-In.
- User account creation/sign-in routes in normal Settings/Backup flow.
- Cloud backup/restore controls in normal Settings/Backup flow.

Release caveat: this pass inspected the current dependency graph, source manifest, debug APK permissions, and current runtime reports. A final signed release AAB and release merged manifest have not yet been generated, so Play Console answers still need one final artifact check.

## 3. Data handled by the app

Confirmed app-handled data:
- Financial records: income, expenses, debts, goals, budgets, transaction notes/categories/dates/amounts, and vault transactions where used.
- App preferences: language, selected currency, notification settings/time, pending quick-entry state, PRO entitlement state.
- Local security settings: PIN/vault PIN values and local security toggles stored through secure storage.
- Backup files: exported/imported JSON backups containing normal and vault financial transaction data.
- Purchase state: one-time PRO product availability, purchase status, restore status, and local `is_pro` entitlement.
- Crash diagnostics: fatal Flutter/platform errors and nonfatal errors sent through Firebase Crashlytics, plus local `error_logs.txt` in app documents storage.
- Notification scheduling data: local reminder channel/time and notification permission behavior.
- Deep link/widget state: quick-entry action/type metadata for the home widget flow.

Not confirmed as app-handled in the current local-only release:
- User name, email, phone number, or app account profile.
- Cloud-hosted financial records.
- Firebase Analytics usage events.
- Firebase Auth accounts.
- Firestore documents.
- Google Sign-In tokens.

## 4. On-device only vs exported/imported vs off-device diagnostics

On-device only by normal app operation:
- Financial records in local SQLite.
- Currency, language, notification preferences, and PRO entitlement preference.
- PIN/vault PIN/security toggles in local secure storage.
- Local reminder schedule.
- Local app error log file.
- Home widget quick-entry state.

Exported/imported only by explicit user action:
- Local backup JSON generated from normal and vault transactions.
- Backup JSON shared through Android share targets.
- Backup JSON imported through Android document picker.

Off-device through active SDK/service behavior:
- Firebase Crashlytics crash reports and nonfatal error reports. Firebase documentation says Crashlytics automatically collects stack traces, relevant app state, relevant device metadata, and a Crashlytics installation UUID; this app also invokes `recordError(error, stack)` for nonfatal errors.
- Firebase Installations/Sessions data included transitively for Crashlytics support.
- Google Play Billing purchase/product/restore data handled by Google Play for the one-time PRO purchase flow.
- External browser request when the user opens the hosted privacy policy URL.

Important distinction: financial records are not uploaded by the app to a developer cloud backend in the current first-release flow. They can still leave the app/device if the user chooses a share/export destination, and diagnostic data can leave the device through Crashlytics.

## 5. Remaining permissions/SDK disclosure implications

Current dependency graph includes:
- `firebase_core`
- `firebase_crashlytics`
- `in_app_purchase`
- `share_plus`
- `file_picker`
- `local_auth`
- `flutter_secure_storage`
- `flutter_local_notifications`
- `home_widget`
- `url_launcher`
- `sqflite`
- `shared_preferences`
- `path_provider`

Current source manifest declares:
- `android.permission.USE_BIOMETRIC`
- `android.permission.USE_FINGERPRINT`
- launcher activity and `gastossimple://quick_entry` deep link
- exported quick-entry widget receiver
- HTTP/HTTPS/process-text queries

Current debug APK permission scan found:
- `android.permission.INTERNET`
- `android.permission.USE_BIOMETRIC`
- `android.permission.USE_FINGERPRINT`
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS`
- `com.android.vending.BILLING`
- `android.permission.ACCESS_NETWORK_STATE`
- `android.permission.WAKE_LOCK`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.FOREGROUND_SERVICE`
- app-scoped dynamic receiver permission

Disclosure implications:
- Crashlytics requires diagnostic/crash/device identifier disclosure.
- Billing requires purchase handling disclosure; exact Play Data Safety category should be manually confirmed in Play Console against Google Play Billing guidance.
- Backup/export/import requires clear privacy language that exported files can contain financial and vault data and are controlled by the user after sharing/saving.
- Biometric/PIN security requires language that biometric authentication is handled by the device OS and biometric templates are not received by the app.
- Notifications require language that reminders are scheduled locally and may require notification permission.
- Internet/network state permissions should be explainable by Crashlytics/Firebase, Billing, and external privacy policy launch.

## 6. Privacy policy alignment status

Status: partial.

Aligned:
- The current visible app behavior is local-only for financial records.
- Settings/Backup do not expose Google sign-in, cloud backup, or cloud restore.
- Account deletion is not required for the first local-only release because no app account creation/sign-in path is user-reachable.

Not aligned:
- The in-app policy says the app does not upload information to external servers. Crashlytics sends diagnostics off-device.
- The in-app policy says no personal or financial data is shared with third parties. This is too broad because Crashlytics sends diagnostic data to Firebase/Google, Billing uses Google Play, and local backup export can transfer financial data to user-selected apps.
- The in-app policy does not clearly disclose Google Play Billing, Crashlytics diagnostics, local notifications, or biometric/PIN behavior.
- The hosted policy URL was identified in source, but the hosted page content/public availability still needs manual verification before Play submission.

Safest privacy policy posture:
- Say financial records are stored locally on the device and are not uploaded to a developer cloud service.
- Say users can manually export/import backups and exported files may contain financial/vault data.
- Say Firebase Crashlytics is used for crash diagnostics and may collect crash logs, stack traces, app state, device metadata, and installation identifiers.
- Say Google Play Billing handles PRO purchases and the app stores only purchase/entitlement state needed to unlock PRO.
- Say biometric authentication is handled by the device OS and the app does not receive biometric templates.
- Say local reminders/notifications are used if enabled/allowed.
- Avoid saying "no external servers," "no third parties," or "no data sharing" without these exceptions.

## 7. Play Data Safety alignment status

Status: partial draft ready, not submission-ready.

Confirmed Data Safety posture:
- Do not answer as "no data collected/shared" because Crashlytics and Billing are active.
- Do not declare Firebase Analytics collection because Analytics is absent.
- Do not declare account, Auth, Firestore, Google Sign-In, or cloud backup collection for the first local-only release.
- Financial records should be described as local app data, not developer-collected server data, unless the Play Console interpretation for user-initiated share/export requires a sharing declaration for on-device transfer to another app.
- Crashlytics should be disclosed under app info/performance diagnostics/crash logs and device or other identifiers as applicable.
- Google Play Billing should be disclosed for purchase-related handling as applicable.

Likely Play Data Safety disclosures:
- App info and performance: crash logs and diagnostics, collected for app functionality/crash reporting.
- Device or other IDs: Crashlytics installation UUID/Firebase installation/session identifiers, collected for crash reporting.
- Financial info / purchase history: Google Play Billing for one-time PRO purchase, collected/processed for app functionality, fraud prevention, security, and compliance as applicable.
- Files/docs or financial info sharing: user-initiated local backup export may transfer a JSON file containing financial records to another app. Confirm exact Play Console treatment before submission.

Likely non-disclosures:
- Location.
- Contacts.
- Photos/videos/audio.
- Calendar.
- Health and fitness.
- Messages.
- Personal info such as name/email/phone, unless Play Billing guidance requires account/payment details handled by Google Play to be reflected.
- App activity analytics/tracking, because Firebase Analytics is absent.

Security practices draft:
- Data transmitted by Firebase/Google SDKs is expected to use encryption in transit.
- Local financial records are stored on device.
- PIN/vault PIN are stored through local secure storage.
- Exported backup files are user-controlled and their protection depends on the selected destination.
- No app account is offered, so account deletion does not apply; users can remove local app data by deleting records, clearing app data, or uninstalling.

## 8. Manual verification items still needed

- Generate the signed release AAB and inspect the release merged manifest before Play submission.
- Confirm the final AAB still excludes Firebase Analytics, Firebase Auth, Cloud Firestore, and Google Sign-In.
- Confirm the release permissions match the debug findings or document differences.
- Update the in-app privacy policy copy and the hosted privacy policy URL with Crashlytics, Billing, backup/export/import, notifications, and biometric/PIN disclosures.
- Verify the hosted privacy policy URL is public, accurate, non-editable by users, and matches the app listing/package/developer.
- Confirm Play Console Data Safety category choices for Google Play Billing purchase history/payment handling.
- Confirm Play Console treatment of user-initiated backup sharing to another app, because Google Play guidance treats on-device transfer to another app as sharing.
- Confirm Crashlytics automatic collection is acceptable as required diagnostics, or add an opt-out/consent posture in a later pass if desired.
- Run an internal Play test for `simple_pro_lifetime` product load, purchase, restore, restart persistence, cancel, pending, and error states.
- Confirm notification permission prompt/runtime behavior on Android 13+ during release smoke.
- Confirm no account creation/sign-in/cloud backup route is reachable in the final release build.

## 9. Exact safest next action

Before signing/AAB generation, update both the in-app and hosted privacy policy to match the current artifact: local financial records, user-controlled backup export/import, Google Play Billing purchases, local security/biometrics, notifications, and Firebase Crashlytics diagnostics. Then generate the signed release AAB, inspect the release merged manifest, and finalize Play Data Safety answers from that exact artifact.
