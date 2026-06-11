# Upload keystore creation guide

## 1. Executive summary

This pass verified the local Java signing tool availability and prepared manual, secret-safe instructions for creating the Play upload keystore. No keystore was created, no passwords or real signing values were collected, no AAB was generated, no release build was run, and no app source code was modified.

The recommended keystore location is outside the app repository:

`$env:USERPROFILE\.android\simple-upload-keystore.jks`

Keeping the keystore outside the repository reduces the chance of accidental commits. The app should still reference it from ignored `android/key.properties` using a local-only path.

## 2. keytool availability

Status: available, but not on PATH.

Observed:

- `keytool -help` failed because `keytool` is not available directly on PATH.
- `JAVA_HOME` is set to `C:\Program Files\Android\Android Studio\jbr`.
- Android Studio's bundled Java runtime includes:
  - `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`
- Running `& "$env:JAVA_HOME\bin\keytool.exe" -help` succeeded.

Use the full PowerShell invocation below unless `keytool` is later added to PATH.

## 3. Recommended keystore path

Recommended local keystore path:

`$env:USERPROFILE\.android\simple-upload-keystore.jks`

Resolved on this machine, that is expected to be under:

`C:\Users\MiguelD\.android\simple-upload-keystore.jks`

Reason:

- It stays outside the app source tree.
- It is a conventional local Android signing-material location.
- It avoids putting the keystore under the repo even though keystore patterns are ignored.

## 4. Exact manual keystore creation command

Run this manually in PowerShell from any directory:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.android"
& "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v -keystore "$env:USERPROFILE\.android\simple-upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias <YOUR_UPLOAD_KEY_ALIAS>
```

When prompted by `keytool`, enter the keystore password, key password, and certificate identity details locally in your terminal. Do not paste passwords into Codex or commit them to the repository.

Choose and record the alias locally. The alias is not a password, but it is still part of the signing configuration and should be written only into ignored `android/key.properties`.

## 5. Exact key.properties fields to fill

Copy the template:

```powershell
Copy-Item android\key.properties.example android\key.properties
```

Then edit `android/key.properties` locally and fill these fields:

```properties
storeFile=C:/Users/MiguelD/.android/simple-upload-keystore.jks
storePassword=<YOUR_KEYSTORE_PASSWORD>
keyAlias=<YOUR_UPLOAD_KEY_ALIAS>
keyPassword=<YOUR_KEY_PASSWORD>
```

Notes:

- Use forward slashes in `storeFile` to avoid Windows backslash escaping issues.
- `android/key.properties` is ignored by git and must remain local only.
- If you choose a different keystore location, update only the ignored local `storeFile` value.

## 6. Git ignore confirmation

Confirmed with `git check-ignore` that signing secret paths are ignored, including:

- `android/key.properties`
- `android/app/key.properties`
- `key.properties`
- `android/upload-keystore.jks`
- `android/release.keystore`
- `android/release.p12`
- `android/release.pfx`
- `upload-keystore.jks`

The recommended keystore path is outside the repository, so it is not tracked by this repo regardless of ignore rules.

## 7. Safety warnings

- Do not commit `android/key.properties`.
- Do not commit the keystore.
- Do not share keystore passwords in Codex, chat, screenshots, tickets, or reports.
- Back up the upload keystore and passwords in a secure password manager or encrypted backup.
- Losing the upload key may require a Play Console upload-key reset process.
- Do not generate the AAB until `android/key.properties` exists locally and points to the keystore.
- Do not change `applicationId`, namespace, billing product IDs, or release config as part of keystore creation.

## 8. Exact next safe action

Manually run the `keytool` command above in PowerShell, copy `android/key.properties.example` to `android/key.properties`, fill the four local signing fields, and then run a separate signed-AAB generation pass.
