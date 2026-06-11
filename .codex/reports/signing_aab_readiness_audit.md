# Signing and AAB readiness audit

## 1. Executive summary

Android release signing is not ready for a production Play upload yet. The Gradle file contains a conditional `release` signing config that only exists when `android/key.properties` is present, but no `key.properties` file and no keystore file were found. Because the current `release` build type falls back to `signingConfigs.debug` when `key.properties` is absent, generating a release AAB now would risk producing a debug-signed release artifact.

The app identity/version values are coherent for the current release candidate: package/application id remains `com.migueld.gastossimple`, visible label is `$imple`, and Android version `1.1.0` / `3` matches `pubspec.yaml` version `1.1.0+3`.

Do not generate an AAB until release signing material is created/configured and the debug-signing fallback is removed or made fail-closed.

## 2. Current Android release config status

Inspected files:

- `android/app/build.gradle`
- `android/settings.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/gradle.properties`
- `android/app/proguard-rules.pro`
- `android/app/google-services.json`
- `lib/firebase_options.dart`
- `pubspec.yaml`

Current config:

- Android Gradle Plugin: `8.9.1`
- Kotlin Android plugin: `2.1.0`
- Google Services plugin: `4.4.1`
- Firebase Crashlytics plugin: `3.0.3`
- `namespace`: `com.migueld.gastossimple`
- `applicationId`: `com.migueld.gastossimple`
- `compileSdk`: `36`
- `targetSdk`: `36`
- `minSdkVersion`: `flutter.minSdkVersion`
- `versionCode`: `3`
- `versionName`: `1.1.0`
- `pubspec.yaml` version: `1.1.0+3`
- Release build:
  - `minifyEnabled true`
  - `shrinkResources true`
  - ProGuard file: `proguard-rules.pro`

Risk note:

- `android.suppressUnsupportedCompileSdk=36` is set. Debug builds have passed in prior reports, but release AAB generation should still verify the local Android/Flutter toolchain against compile SDK 36.

## 3. Signing status

Status: partial / not production-ready.

What exists:

- `android/app/build.gradle` loads `rootProject.file('key.properties')`, which resolves to `android/key.properties`.
- If that file exists, Gradle creates `signingConfigs.release` using:
  - `keyAlias`
  - `keyPassword`
  - `storeFile`
  - `storePassword`

What is missing:

- `android/key.properties`: not found.
- `android/app/key.properties`: not found.
- repository-root `key.properties`: not found.
- Keystore files (`*.jks`, `*.keystore`, `*.p12`, `*.pfx`): none found in the repo.

Current release risk:

- `buildTypes.release.signingConfig` is:
  - `keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug`
- This means a release build without `android/key.properties` falls back to debug signing.
- That fallback is unsafe for a Play production/internal release because it can hide missing signing setup and produce the wrong signing certificate.

Secrets check:

- No keystore file or signing password file was found committed.
- `android/app/google-services.json` and `lib/firebase_options.dart` are tracked and contain Firebase client API keys. This is normal for Firebase client config, but the keys should be restricted in Google Cloud/Firebase Console before release.
- `.gitignore` does not currently include `key.properties`, `*.jks`, `*.keystore`, `*.p12`, or `*.pfx`; add ignores before generating signing material in the workspace.

## 4. AAB readiness status

Status: not ready to generate a signed release AAB safely.

Reasons:

- Release signing material is missing.
- Release build currently falls back to debug signing when signing material is absent.
- No release AAB output was found:
  - `build/app/outputs/bundle/release`: absent.
  - `android/app/build/outputs/bundle/release`: absent.
- No release merged manifest was found.
- No release manifest merger report was found.

Technical build readiness is plausible because debug builds have passed in prior reports, but a signed release AAB should wait until signing is configured fail-closed and then be validated from the exact generated artifact.

## 5. Versioning status

Status: coherent.

- `pubspec.yaml`: `version: 1.1.0+3`
- `android/app/build.gradle`:
  - `versionName "1.1.0"`
  - `versionCode 3`

Recommendation:

- Keep `versionCode 3` only if it has not already been uploaded to Play for this package.
- If any previous internal/closed/production upload used version code `3`, increment before generating the release AAB.

## 6. Manifest/permissions findings

Source manifest:

- Package: `com.migueld.gastossimple`
- App label: `$imple`
- Launcher activity: `.MainActivity`
- Deep link:
  - scheme: `gastossimple`
  - host: `quick_entry`
- Widget receiver:
  - `.QuickEntryWidgetProvider`
  - `android:exported="true"`
- Declared permissions:
  - `android.permission.USE_BIOMETRIC`
  - `android.permission.USE_FINGERPRINT`
- Queries:
  - `https`
  - `http`
  - `PROCESS_TEXT` for `text/plain`

Debug merged manifest observations from existing generated output:

- Permissions seen in the existing debug merged manifest include:
  - `INTERNET`
  - `USE_BIOMETRIC`
  - `USE_FINGERPRINT`
  - `VIBRATE`
  - `POST_NOTIFICATIONS`
  - `ACCESS_NETWORK_STATE`
  - `com.android.vending.BILLING`
  - `com.google.android.providers.gsf.permission.READ_GSERVICES`
  - `WAKE_LOCK`
  - `RECEIVE_BOOT_COMPLETED`
  - `FOREGROUND_SERVICE`
  - app-scoped dynamic receiver permission
- Components from share, home widget/glance, WorkManager/AndroidX startup, Billing, Firebase, and URL launcher were present.

Important caveat:

- The existing debug merged manifest appears stale in parts and still contains Auth/Firestore/Google Sign-In components from older dependency states.
- Current `pubspec.yaml`, `pubspec.lock`, `.flutter-plugins-dependencies`, and `.dart_tool/package_config.json` show Firebase Core, Firebase Crashlytics, and In-App Purchase, but not Firebase Auth, Cloud Firestore, Google Sign-In, or Firebase Analytics.
- Therefore, do not use the existing debug merged manifest as final Play disclosure proof. Generate and inspect a fresh release merged manifest after signing config is fixed.

Data Safety implications to verify from the final release artifact:

- Crashlytics diagnostics and device/installation identifiers.
- Google Play Billing purchase handling.
- User-initiated local backup export/import through share/file picker.
- Local notifications and related notification/boot/wake permissions.
- Biometric/PIN local security.
- Home widget/deep link behavior.
- Internet/network permissions used by Firebase/Crashlytics, Billing, and privacy URL launch.

## 7. Crashlytics/Billing release implications

Crashlytics:

- `firebase_core` and `firebase_crashlytics` are present.
- `com.google.gms.google-services` and `com.google.firebase.crashlytics` Gradle plugins are applied.
- `android/app/google-services.json` package name is `com.migueld.gastossimple`, matching `applicationId`.
- `lib/firebase_options.dart` contains Android Firebase options for project `simple-app-78147`.
- ProGuard keeps Crashlytics classes and source/line metadata.
- Release upload should verify Crashlytics mapping file behavior and confirm no Firebase Analytics/Auth/Firestore/Google Sign-In components appear in the release artifact.

Billing:

- `in_app_purchase` is present.
- Product id remains `simple_pro_lifetime`.
- Existing reports say entitlement flow is fixed, but store-side product setup and internal-track real purchase/restore remain unverified.
- Release artifact should include `com.android.vending.BILLING`; this must be confirmed from the fresh release merged manifest.

## 8. Missing items before AAB generation

- Create or obtain a Play upload keystore.
- Add `android/key.properties` locally with release signing values.
- Ensure keystore and key property files are ignored before creation:
  - `android/key.properties`
  - `*.jks`
  - `*.keystore`
  - `*.p12`
  - `*.pfx`
- Change release signing behavior so missing signing material fails the build instead of falling back to debug signing.
- Generate a signed release AAB only after signing config is fixed.
- Inspect the release merged manifest and final dependency/plugin set.
- Confirm `versionCode 3` is unused in Play, or increment before upload.
- Confirm Firebase API key restrictions in Firebase/Google Cloud Console.
- Confirm `simple_pro_lifetime` is active in Play Console before internal billing smoke.

## 9. Exact safest next action

Before generating an AAB, make a signing-prep patch that:

1. Adds ignore rules for local signing files.
2. Changes `buildTypes.release` to fail when `android/key.properties` is missing instead of using `signingConfigs.debug`.
3. Documents the required local `android/key.properties` fields without committing secrets.

After that, create the upload keystore locally, add `android/key.properties`, generate the signed release AAB, inspect the release merged manifest, and finalize Play Data Safety from the generated artifact.
