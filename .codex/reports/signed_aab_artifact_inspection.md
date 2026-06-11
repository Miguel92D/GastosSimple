# Signed AAB artifact inspection

## 1. Executive summary

The signed release AAB at `build/app/outputs/bundle/release/app-release.aab` exists and is inspectable. The artifact matches the intended release posture: visible app label `$imple`, package `com.migueld.gastossimple`, version `1.1.0` / `3`, local-first app behavior, Google Play Billing for PRO, and Firebase Crashlytics diagnostics.

The exact release manifest confirms Google Play Billing and Firebase Crashlytics/Firebase Core support components are present. Firebase Auth, Cloud Firestore, Google Sign-In, and Firebase Analytics app SDKs are not present in the release plugin metadata, dependency metadata, merged manifest, or class-path searches used for this pass.

No app source, business logic, billing logic, Android release config, signing config, package identifiers, or AAB output were modified or regenerated in this pass.

## 2. AAB verification

- AAB path: `build/app/outputs/bundle/release/app-release.aab`
- Exists: yes
- Size: `54,077,867` bytes
- Last modified: `2026-05-14 18:41:28`
- Previous signing pass verified `jarsigner -verify` returned `jar verified`.
- Inspected existing release outputs:
  - `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`
  - `build/app/outputs/logs/manifest-merger-release-report.txt`
  - extracted AAB contents under `build/aab_inspect_pass`
  - `BUNDLE-METADATA/com.android.tools.build.gradle/app-metadata.properties`
  - `BUNDLE-METADATA/com.android.tools.build.libraries/dependencies.pb`

## 3. Manifest findings

Final release identity:

- Package / applicationId: `com.migueld.gastossimple`
- Version code: `3`
- Version name: `1.1.0`
- minSdk: `24`
- targetSdk: `36`
- App label: `$imple`
- Launcher activity: `com.migueld.gastossimple.MainActivity`

Deep links and queries:

- Main launcher activity has `MAIN` / `LAUNCHER`.
- Deep link present:
  - scheme: `gastossimple`
  - host: `quick_entry`
- Package visibility queries include:
  - `https`
  - `http`
  - `PROCESS_TEXT` for `text/plain`
  - `GET_CONTENT` for `*/*`
  - Google Play Billing bind actions

Widgets/components:

- `com.migueld.gastossimple.QuickEntryWidgetProvider`
  - exported: `true`
  - action: `android.appwidget.action.APPWIDGET_UPDATE`
  - metadata: `@xml/widget_info`
- AndroidX Glance app widget trampoline activities, receivers, and remote views services are present.

## 4. SDK/dependency findings

Confirmed from release manifest and dependency metadata:

- Google Play Billing:
  - `com.android.vending.BILLING`
  - `com.android.billingclient:billing:7.1.1`
  - `com.google.android.play.billingclient.version` = `7.1.1`
  - `ProxyBillingActivity`
  - `ProxyBillingActivityV2`
- Firebase Crashlytics / Firebase Core support:
  - Flutter Firebase Core registrar
  - Flutter Firebase Crashlytics registrar
  - `FirebaseCrashlyticsKtxRegistrar`
  - `CrashlyticsRegistrar`
  - Firebase Sessions
  - Firebase Installations
  - Firebase DataTransport / CCT transport
  - `FirebaseInitProvider`
- Other relevant plugins/components:
  - `share_plus`
  - `file_picker`
  - `url_launcher_android`
  - `flutter_local_notifications`
  - `local_auth_android`
  - `flutter_secure_storage`
  - `home_widget`
  - `sqflite_android`
  - `shared_preferences_android`

Nuance:

- `firebase-measurement-connector` appears as a transitive Firebase support library, but `firebase_analytics` / `firebase-analytics` is absent and no Firebase Analytics app SDK, Analytics manifest service/receiver, or `FirebaseAnalytics` class evidence was found.
- `play-services-location` and `play-services-places-placereport` appear as transitive Google Play services libraries in the manifest merger report, but no location permission is declared in the final release manifest.

## 5. Permissions/components findings

Final release permissions:

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

Providers:

- `dev.fluttercommunity.plus.share.ShareFileProvider`
  - exported: `false`
  - grant URI permissions: `true`
  - used for share/export file access
- `com.google.firebase.provider.FirebaseInitProvider`
  - exported: `false`
  - Firebase initialization
- `androidx.startup.InitializationProvider`
  - exported: `false`
  - WorkManager, lifecycle, profile installer initialization

Services:

- Firebase Component Discovery service
- Firebase Sessions lifecycle service
- DataTransport backend/job scheduling services
- AndroidX WorkManager services
- AndroidX Glance / RemoteViews services
- AndroidX Room multi-instance invalidation service

Receivers:

- App widget receiver for quick entry
- Share chooser callback receiver
- AndroidX Glance receivers
- AndroidX WorkManager receivers
- AndroidX ProfileInstaller receiver
- DataTransport scheduler receiver

## 6. Confirmed included SDKs

- Firebase Core
- Firebase Crashlytics
- Firebase Sessions / Installations / DataTransport support required by Crashlytics
- Google Play Billing `7.1.1`
- Google Play services base/tasks support
- Local auth / AndroidX biometric support
- Flutter local notifications support
- Share/file picker support
- URL launcher support
- Home widget / AndroidX Glance support
- SQLite/shared preferences/path provider support

## 7. Confirmed absent SDKs

Confirmed absent from the current release artifact checks:

- Firebase Auth
- Cloud Firestore
- Google Sign-In
- Firebase Analytics app SDK

Evidence:

- No `firebase_auth`, `cloud_firestore`, `google_sign_in`, or `firebase_analytics` packages in `.flutter-plugins-dependencies`, `.dart_tool/package_config.json`, or `pubspec.lock`.
- No Firebase Auth, Firestore, Google Sign-In, or Firebase Analytics manifest services/providers/activities in the release merged manifest.
- AAB dependency metadata search found:
  - `firebase-auth`: absent
  - `firebase-firestore`: absent
  - `firebase-analytics`: absent
  - `play-services-auth`: absent
  - `google_sign_in`: absent
  - `cloud_firestore`: absent
  - `firebase_analytics`: absent
- Dex class-path search found:
  - `firebase/auth`: absent
  - `firebase/firestore`: absent
  - `firebase/analytics`: absent
  - `google/android/gms/auth/api/signin`: absent
  - `GoogleSignIn`: absent
  - `FirebaseAnalytics`: absent

Note: the text `FirebaseAuth` appears as a string in the compiled artifact, consistent with privacy/exclusion wording, but the Firebase Auth SDK class path and dependency are absent.

## 8. Data Safety final findings

Data Safety relevant items from the exact signed release artifact:

- Network access:
  - `INTERNET`
  - `ACCESS_NETWORK_STATE`
  - used by Firebase/Crashlytics, Billing, DataTransport, Google services support, and external privacy URL launch.
- Billing:
  - `com.android.vending.BILLING`
  - Billing Client `7.1.1`
  - disclose one-time PRO purchase handling through Google Play Billing.
- Crash diagnostics:
  - Firebase Crashlytics present.
  - Firebase Sessions, Installations, and DataTransport present.
  - disclose crash logs, diagnostics, relevant app/device metadata, and installation/session identifiers as applicable.
- Local backup/export/import:
  - `share_plus` file provider is present.
  - `file_picker` query for `GET_CONTENT */*` is present.
  - disclose user-initiated backup export/import and that exported backup files can contain financial/vault records.
- Notifications:
  - `POST_NOTIFICATIONS`, `VIBRATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, and `FOREGROUND_SERVICE` are present.
  - disclose local reminders/notification permission behavior.
- Biometrics/fingerprint:
  - `USE_BIOMETRIC`
  - `USE_FINGERPRINT`
  - disclose device-OS biometric handling and that the app does not receive biometric templates.
- Storage/file sharing/provider behavior:
  - `ShareFileProvider` grants URI permissions for shared files.
  - File export/import is user initiated and destination controlled by the user.
- Widgets/deep links:
  - Home widget receiver and `gastossimple://quick_entry` deep link are present.
  - disclose only if Play Console asks about app functionality/components; they do not create a separate data collection category by themselves.

Data Safety posture:

- Do not answer as "no data collected/shared."
- Do not disclose Firebase Analytics, Auth, Firestore, Google Sign-In, app account, or cloud backup for this release.
- Treat financial records as local app data, with an explicit caveat for user-initiated backup export/share.
- Disclose Crashlytics diagnostics and Google Play Billing.

## 9. Remaining manual Play Console decisions

- Select exact Play Console categories for Google Play Billing purchase handling:
  - likely `Financial info > Purchase history`
  - payment method details should not be marked as collected by app code unless Play Console wording requires it for Google Play Billing.
- Decide how Play Console wants user-initiated backup export/share represented:
  - `Files and docs`
  - `Financial info`
  - both, depending on the form wording.
- Confirm whether Crashlytics diagnostics are marked required or optional. With current automatic collection, treat them as required for diagnostics/crash reporting.
- Confirm Data Safety "shared" answers for Firebase/Google service-provider handling versus user-initiated export/share.
- Confirm `simple_pro_lifetime` product is active and testable in Play Console internal testing.
- Confirm notification prompt/reminder behavior on Android 13+ during internal test.
- Upload the generated AAB only after the Play Console Data Safety form and privacy policy URL are final.

## 10. Exact next safe action

Finalize the Play Console Data Safety form using this signed AAB inspection, then upload `build/app/outputs/bundle/release/app-release.aab` to an internal testing track and run a billing/purchase/restore smoke test for `simple_pro_lifetime`.
