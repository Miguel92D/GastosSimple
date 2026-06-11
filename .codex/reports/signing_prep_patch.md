# Signing prep patch

## 1. Executive summary

Signing-prep-only patch applied. Android release signing now fails closed for release assemble/bundle/package signing tasks when `android/key.properties` is missing, incomplete, or points to a missing keystore. The previous debug-signing fallback for release builds was removed.

No keystore was created, no AAB was generated, no release build was run, and no app business logic, billing logic, privacy content, app identifiers, package names, or version values were changed.

## 2. Files modified

- `.gitignore`
- `android/app/build.gradle`
- `android/key.properties.example`
- `.codex/reports/signing_prep_patch.md`

## 3. .gitignore signing-secret rules applied

The repository now ignores local Android signing material:

- `android/key.properties`
- `**/key.properties`
- `android/*.jks`
- `android/*.keystore`
- `android/*.p12`
- `android/*.pfx`
- `*.jks`
- `*.keystore`
- `*.p12`
- `*.pfx`

Static check confirmed these sample secret paths are ignored:

- `android/key.properties`
- `android/upload-keystore.jks`
- `android/release.keystore`
- `android/release.p12`
- `android/release.pfx`
- `release.jks`

## 4. key.properties.example status

Added `android/key.properties.example` with placeholder values only:

- `storeFile=../path/to/upload-keystore.jks`
- `storePassword=CHANGE_ME`
- `keyAlias=CHANGE_ME`
- `keyPassword=CHANGE_ME`

This file is documentation/template only. It does not contain real credentials, aliases, passwords, or a real keystore path.

## 5. Release signing fail-closed behavior

Updated `android/app/build.gradle` so release signing no longer falls back to `signingConfigs.debug`.

Release signing validation now throws a clear `GradleException` when a release assemble/bundle/package signing task is requested and:

- `android/key.properties` is missing.
- `storeFile`, `storePassword`, `keyAlias`, or `keyPassword` is missing or blank.
- The keystore referenced by `storeFile` does not exist.

The release build type applies `signingConfigs.release` only when `android/key.properties` exists. Debug signing remains scoped to the debug build type.

## 6. What still must be done manually

- Create or obtain the Play upload keystore.
- Copy `android/key.properties.example` to `android/key.properties`.
- Fill `android/key.properties` locally with real signing values.
- Keep the keystore and `android/key.properties` out of git.
- Generate the signed release AAB only after local signing files exist.
- Inspect the fresh release merged manifest and final AAB dependency set.
- Confirm `versionCode 3` has not already been used in Play, or increment in a later versioning pass before upload.

## 7. Exact next safe action

Create the upload keystore locally and fill `android/key.properties` from the template, then run the signed release AAB generation in a separate pass and inspect the generated release manifest before Play upload.
