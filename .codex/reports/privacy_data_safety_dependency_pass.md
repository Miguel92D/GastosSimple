# Privacy/Data Safety Dependency Pass

Audit date: 2026-05-12

Scope: audit-only dependency, permission, SDK, and reachable-flow review for the planned first local-only Play Store release. No application source, business logic, Android release config, signing material, or release build settings were modified.

Skills applied: seguridad-android-play, auditor-dependencias-flutter.

Policy references checked:
- Google Play Data safety form: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play account deletion requirement: https://support.google.com/googleplay/android-developer/answer/13327111
- Google Play Developer Program Policy, User Data / account deletion: https://support.google.com/googleplay/android-developer/answer/16543315

Note: `.codex/checklists/play_console_answers_draft.md` was requested but is not present in this workspace.

## 1. Executive summary

The first-release user experience is local-only, but the current dependency set is not cleanly local-only. Normal Settings and Backup flows expose local backup/import/export only; `/auth` is not routed; `AuthService` is not registered in `main.dart`; transaction changes no longer call cloud backup. That means Google account creation is not currently user-reachable and account deletion should not apply to the first local-only release.

The remaining Play risk comes from active and linked SDK behavior:

- Firebase Analytics is active at startup via `FirebaseAnalytics.instance.logAppOpen()` and via `ErrorService.logError()`.
- Crashlytics is active at startup through Flutter and platform error handlers.
- Firebase Core is active at startup.
- Firebase Auth, Firestore, and Google Sign-In are still dependencies and appear in the debug merged manifest through native components, even though the app no longer exposes normal routes to them.
- In-app purchase/billing is active and user-reachable from Premium.
- Local backup/export/import is active and user-reachable; it exports financial and vault transaction data to a JSON file and sends it through Android share/file-picker surfaces.
- Local auth/secure storage, notifications, home widget/deep link, URL launcher, SQLite/shared preferences, and file storage remain relevant to privacy/Data Safety.

Single safest posture: do not start signing yet. Remove or compile-disable unused auth/cloud SDKs before release, and either remove/disable Analytics/Crashlytics for the strictest local-only promise or update privacy/Data Safety to disclose them accurately. Then generate Data Safety answers from the final release dependency set.

## 2. SDKs/features inspected

Sources inspected:

- `pubspec.yaml`
- `pubspec.lock`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle`
- existing debug merged manifest: `android/app/build/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml`
- `lib/main.dart`
- `lib/services/error_service.dart`
- `lib/services/purchase_service.dart`
- `lib/services/notification_service.dart`
- `lib/services/security_service.dart`
- `lib/services/auth_service.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/controllers/backup_controller.dart`
- `lib/features/settings/screens/premium_screen.dart`
- `lib/features/settings/screens/privacy_policy_screen.dart`
- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`

SDKs/features reviewed:

- Firebase Core
- Firebase Analytics
- Firebase Crashlytics
- Firebase Auth
- Cloud Firestore
- Google Sign-In
- Google Play Billing / `in_app_purchase`
- Local backup/export/import / `share_plus` / `file_picker` / `path_provider`
- Local auth / biometrics / `flutter_secure_storage`
- Local notifications / `flutter_local_notifications`
- Home widget / app widget deep link
- URL launcher / hosted privacy policy link
- SQLite / shared preferences / local app storage
- Android permissions and plugin-merged manifest components

## 3. Classification per SDK/feature

| SDK/feature | Current evidence | Classification | First-release risk |
| --- | --- | --- | --- |
| Firebase Core | `firebase_core` dependency; `Firebase.initializeApp()` in `main.dart`; Firebase init provider in merged manifest. | Active but not directly user-reachable. | Medium. Enables Firebase SDK runtime and must be consistent with privacy copy if any Firebase SDK remains. |
| Firebase Analytics | `firebase_analytics` dependency; `FirebaseAnalytics.instance.logAppOpen()` in `main.dart`; `ErrorService.logError()` logs `app_error`. | Active but mostly background/not directly user-reachable. | High. Current privacy text says no tracking/no third parties, which conflicts with active analytics. Data Safety must disclose analytics/app activity/diagnostic event collection as applicable. |
| Firebase Crashlytics | `firebase_crashlytics` dependency; `FlutterError.onError` and `PlatformDispatcher.instance.onError` send errors to Crashlytics. | Active but hidden/not user-reachable. | High. Privacy policy and Data Safety must disclose crash/diagnostic collection if it ships. |
| Firebase Auth | `firebase_auth` dependency; `AuthService` exists; native Firebase Auth activities/components appear in debug merged manifest. `AuthService` is not registered and `/auth` is not routed. | Linked in artifact but not functionally used by normal release flow. | Medium. Does not trigger account deletion by itself, but creates review/Data Safety ambiguity and future regression risk. |
| Cloud Firestore | `cloud_firestore` dependency; `CloudBackupService` exists; Firestore components appear in debug merged manifest. No visible backup/cloud route calls it. | Linked in artifact but not functionally used by normal release flow. | Medium-high. It is unused for the local-only release but strongly contradicts the simple local-only story if left in the artifact. |
| Google Sign-In | `google_sign_in` dependency; `AuthService.signInWithGoogle()` exists; Sign-In native activity/service appear in debug merged manifest. No visible route calls it. | Linked in artifact but not functionally used by normal release flow. | Medium. Account deletion does not apply while hidden, but Play reviewers and Data Safety review may question why it ships in a local-only app. |
| Billing / in-app purchase | `in_app_purchase` dependency; `PurchaseService.init()` runs at startup; Premium screen calls buy/restore; merged manifest includes `com.android.vending.BILLING`. | Active and user-reachable. | Medium-high. Must be disclosed/handled consistently; product setup and purchase verification remain release tasks. |
| Local backup/export/import | Settings exposes local backup; Backup uses `Share.shareXFiles()` and `FilePicker`; `BackupController.exportBackup()` writes all normal and vault transactions to JSON. | Active and user-reachable. | High. Financial/vault data can leave app storage by user action. Privacy policy/Data Safety must explain export/import/share behavior clearly. |
| Local auth / biometrics | Settings exposes PIN, vault PIN, biometric unlock; manifest declares `USE_BIOMETRIC` and `USE_FINGERPRINT`; `flutter_secure_storage` stores PIN/security flags. | Active and user-reachable. | Medium. Privacy should describe local security storage and biometric use; Data Safety may need account/security/local device behavior alignment, even if biometric templates are handled by OS and not collected by the app. |
| Local notifications | `NotificationService.init()` and `scheduleDailyReminder()` run at startup; debug merged manifest includes `POST_NOTIFICATIONS`, `VIBRATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`. | Active, partly user-facing; default enabled unless preference is false. | Medium. Must be aligned with permission prompts and privacy copy; release merged manifest must be reviewed. |
| Home widget/deep link | `HomeWidget` initialized in `main.dart`; manifest has exported widget receiver and `gastossimple://quick_entry` deep link. | Active and user-reachable via widget/deep link. | Low-medium. Mostly functionality/manifest risk; privacy risk depends on widget data displayed/stored. |
| URL launcher | Privacy screen opens hosted policy URL through external browser. Manifest has `queries` for HTTP/HTTPS. | Active and user-reachable. | Low. Privacy URL must be public, accurate, and match app/developer identity. |
| SQLite/local storage | `sqflite`, `shared_preferences`, app documents/temp directories used for financial records, preferences, backups, logs. | Active and user-reachable. | Medium. Supports local-only posture, but policy must accurately describe local financial data, backup files, and logs. |
| Debug/profile INTERNET permission | Debug merged manifest includes `INTERNET` from debug profile comments; release merged manifest was not generated. Firebase/Google SDKs may also need network capability. | Release status unverified. | Medium. Must inspect release merged manifest before Play submission. |

## 4. Privacy policy implications

Current in-app privacy copy is not accurate for the current dependency/runtime set. It says:

- financial data is stored locally;
- no information is uploaded to external servers;
- no personal or financial data is shared with third parties;
- behavior is not tracked outside the app.

That copy is only accurate for the visible financial/cloud product flow. It is not accurate for:

- Firebase Analytics startup and error events;
- Crashlytics fatal/nonfatal crash reporting;
- active billing flow through Google Play;
- local backup export/share where the user can send financial and vault data outside the app;
- local notification permissions and scheduling;
- external browser launch to the hosted privacy policy;
- any remaining native Auth/Firestore/Google Sign-In components if they ship.

Minimum privacy policy correction if current SDK set ships:

- explicitly state that the app is local-first for financial records and does not upload financial records to cloud backup in the first release;
- disclose Firebase Analytics and Crashlytics if enabled, including the purpose: app usage/basic events and crash diagnostics;
- disclose Google Play Billing for Premium purchases;
- disclose local backup export/import and that exported JSON files may contain normal and vault financial records and are controlled by the user after sharing/saving;
- disclose local PIN/security settings and OS biometric authentication;
- disclose notifications/reminders;
- ensure the hosted URL is public, non-PDF, non-editable, app/developer-scoped, and matches the in-app policy.

Strict local-only posture alternative:

- remove/disable Analytics and Crashlytics, and remove unused Auth/Firestore/Google Sign-In SDKs from the release artifact, then the privacy policy can stay much closer to "financial data stays local" while still documenting backups, billing, notifications, and local security.

## 5. Play Data Safety implications

Google Play requires the Data Safety form to cover app behavior and data handled through third-party SDKs used in the app. For this app, Data Safety cannot currently be answered as "no data collected/shared" if Analytics/Crashlytics/Billing remain active.

Likely disclosure areas if shipping the current SDK set:

- App activity / app interactions: Firebase Analytics `logAppOpen()` and `app_error` event.
- App info and performance / crash logs / diagnostics: Crashlytics and error reporting.
- Financial info: local expense/income/debt/goal/vault data is stored on device. It is not uploaded by cloud backup in the current user flow, but it can be exported by the user through local backup/share.
- Purchases: Google Play Billing for `simple_pro_lifetime`.
- Files and docs or user-provided files: backup JSON export/import through share/file picker.
- Device or other IDs: possible through Firebase/Google SDK diagnostics/analytics/billing behavior; confirm with SDK provider guidance before final form.
- Security practices: data encrypted in transit for active SDK network calls, local secure storage for PIN/security state, and user-controlled local backup files.

Data Safety should not claim cloud backup, account sync, or server-side financial storage for the first release if Auth/Firestore stay hidden and no upload path is reachable. But if Auth/Firestore/Google Sign-In remain in the artifact, the safer release path is to remove them before generating final Data Safety answers rather than trying to explain unused cloud SDKs.

Release merged manifest must still be generated and reviewed. The existing debug merged manifest shows plugin-added permissions/components including `POST_NOTIFICATIONS`, `ACCESS_NETWORK_STATE`, `com.android.vending.BILLING`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`, Firebase Auth activities, Google Sign-In service/activity, Firebase init provider, Firestore/Auth registrars, share provider, widget services, and WorkManager components. Debug-only `INTERNET` may differ from release, so do not finalize Play declarations from the debug manifest alone.

## 6. Account deletion requirement status

Does account deletion apply for the first local-only release: no.

Reasoning:

- `/auth` is not registered in `AppRouter`.
- `AppRoutes.auth` is absent.
- Settings does not expose Google account or sign-in.
- Backup does not expose Google sign-in, cloud backup, or cloud restore.
- `AuthService` is not registered in the provider tree in `main.dart`.
- The local-only smoke test confirmed no normal Settings/Backup auth/cloud entry points.

Important condition:

This conclusion only holds if the shipped app does not allow users to create or sign into an app account from any in-app path. If Google sign-in, Firebase Auth, account creation, cloud backup, or restore is reintroduced before release, account deletion and associated web deletion request flow immediately become required.

## 7. Hidden auth/cloud risk assessment

Hidden auth/cloud code does not currently create a user-facing account deletion requirement, but it still creates Play release risk.

Risk factors:

- `firebase_auth`, `cloud_firestore`, and `google_sign_in` remain in `pubspec.yaml` and `pubspec.lock`.
- Debug merged manifest includes Firebase Auth activities, Firebase Auth/Firestore component registrars, Google Sign-In activities/services, Firebase init provider, and Google Play Services metadata.
- `lib/services/cloud_backup_service.dart` still contains code that can upload normal and vault transactions to Firestore if called.
- `lib/services/auth_service.dart` still contains Google Sign-In and Firebase credential creation logic.
- No delete account/delete cloud data implementation exists.
- A future route/settings regression could expose account/cloud behavior quickly.

Assessment:

- User-flow risk: currently low.
- Data Safety/review ambiguity risk: medium.
- Sensitive financial data leakage risk if accidentally reconnected: high.

Safest mitigation before release:

- remove or conditionally exclude Auth/Firestore/Google Sign-In dependencies and unreachable auth/cloud source from the first-release artifact, or hard-disable the code behind a release flag that also removes native plugin linkage where possible.

## 8. Safest release posture recommendation

Recommended posture: remove/disable some SDKs before release and postpone signing until that cleanup is done.

Do not ship the current SDK set as-is unless you are willing to rewrite the privacy policy and Data Safety form to disclose Analytics, Crashlytics, Billing, local export/share/import, notifications, local auth, and the presence/behavior of Google/Firebase SDKs. That is possible, but it is not the cleanest local-only release posture.

Safest local-only release posture:

- Keep local expense storage, local backup/export/import, PIN/biometric protection, notifications if intentionally desired, Premium billing if the product is configured, and URL launcher for privacy policy.
- Remove or compile-disable `firebase_auth`, `cloud_firestore`, and `google_sign_in` from the release artifact because account/cloud is not shipping.
- Decide explicitly whether Firebase Analytics and Crashlytics are worth keeping. For the strictest local-only privacy message, disable/remove them before release. If kept, update privacy policy and Data Safety to disclose diagnostics/analytics clearly.
- Generate a release merged manifest after cleanup and base Play declarations on that artifact, not the current debug manifest.

## 9. Exact safest next action

Before signing work, run a scoped SDK cleanup decision pass:

1. Remove or release-disable unused first-release auth/cloud dependencies: `firebase_auth`, `cloud_firestore`, and `google_sign_in`.
2. Decide whether to keep or remove Firebase Analytics and Crashlytics for v1 local-only.
3. Update the in-app and hosted privacy policy to match that final decision.
4. Draft Play Data Safety answers from the final dependency set.
5. Only after those policy/dependency decisions are implemented and reviewed, proceed to release signing, release merged-manifest review, and signed AAB generation.
