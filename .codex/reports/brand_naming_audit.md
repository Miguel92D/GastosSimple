# Brand naming audit

## 1. Executive summary

Visible product branding is mostly already aligned to `$imple` in the Flutter app shell, launcher labels, drawer, Premium screen, privacy text, widget label, and landing/privacy pages.

No `Gastos Simple`, `gasto simple`, or `gastos simple` public text was found in source/docs outside generated or historical logs. The remaining visible/public mismatch is web/PWA metadata still using `gastos_simple`, and the in-app privacy policy online URL still points to the old `GastosSimple` GitHub Pages path.

Technical identifiers still use `gastos_simple`, `gastossimple`, `GastosSimpleApp`, `simple_pro_lifetime`, and Firebase project ids. These should stay unchanged in this pass because they affect imports, package identity, bundle ids, product ids, Firebase config, deep links, app groups, and billing.

## 2. Current visible branding issues found

- `web/index.html`: public web metadata still exposes `gastos_simple`.
  - `meta name="apple-mobile-web-app-title" content="gastos_simple"`
  - `<title>gastos_simple</title>`
- `web/manifest.json`: PWA install metadata still exposes `gastos_simple`.
  - `"name": "gastos_simple"`
  - `"short_name": "gastos_simple"`
  - `"description": "A new Flutter project."`
- `README.md`: repository documentation still reads like the default Flutter template and starts with `# gastos_simple`. This is documentation-facing, but may be kept technical if README is intended for developers only.
- `lib/features/settings/screens/privacy_policy_screen.dart`: the online policy URL points to the old GitHub Pages path:
  - `https://miguel92d.github.io/GastosSimple/privacy.html`
- `docs/index.html`, `docs/privacy.html`, `SimpleLanding/index.html`, and `SimpleLanding/privacy.html`: visible brand is already `$imple`; copyright/footer uses `$IMPLE APP`, which is visually aligned but should be manually confirmed as intentional casing.

## 3. Files with user-facing text that should change to "$imple"

- `web/index.html`
  - Change public page title and Apple web app title from `gastos_simple` to `$imple`.
  - Consider changing `meta name="description"` from default Flutter text to public `$imple` copy.
- `web/manifest.json`
  - Change installable web app `name` and `short_name` from `gastos_simple` to `$imple`.
  - Consider replacing default description with public `$imple` copy.
- `README.md`
  - If README is public product documentation, change visible heading/copy from `gastos_simple` and default Flutter text to `$imple`.
  - If README is developer-only, keep technical naming but add a public-brand note.
- `lib/features/settings/screens/privacy_policy_screen.dart`
  - The in-app button label is fine, but the URL should no longer use `GastosSimple` in the public path.

Already aligned to `$imple`:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/layout/widget_layout.xml`
- `ios/Runner/Info.plist`
- `lib/main.dart` MaterialApp title
- `lib/features/dashboard/screens/home_screen.dart`
- `lib/core/ui/app_drawer.dart`
- `lib/features/settings/screens/splash_screen.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/consent_screen.dart`
- `lib/features/settings/screens/privacy_policy_screen.dart` visible policy copy
- `lib/features/settings/screens/premium_screen.dart` via `simple_pro` translation
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_localizations*.dart`
- `lib/core/i18n/app_translations.dart`
- `docs/index.html`
- `docs/privacy.html`
- `SimpleLanding/index.html`
- `SimpleLanding/privacy.html`

## 4. Technical identifiers that should not be changed yet

- `pubspec.yaml`: `name: gastos_simple`
- Dart imports using `package:gastos_simple/...`
- `lib/main.dart`: `GastosSimpleApp`, `_GastosSimpleAppState`
- Android namespace/application id:
  - `android/app/build.gradle`: `com.migueld.gastossimple`
  - `android/app/src/main/AndroidManifest.xml`: `package="com.migueld.gastossimple"`
  - `android/app/src/main/kotlin/com/migueld/gastossimple/**`
- Android deep link scheme:
  - `gastossimple://quick_entry`
- iOS bundle identifiers:
  - `com.gastossimple.gastosSimple`
  - related RunnerTests bundle ids
- Home widget app group:
  - `group.example.gastos_simple`
- Firebase config/project ids:
  - `.firebaserc`: `simple-app-78147`
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Billing/product ids:
  - `simple_pro_lifetime`
  - any purchase product id or entitlement identifier
- Generated files and build artifacts under `build/**`, `android/app/build/**`, `android/app/.cxx/**`, `macos/Flutter/ephemeral/**`.

## 5. URLs/GitHub references that should use simple-app-ar

- `lib/features/settings/screens/privacy_policy_screen.dart`
  - Current: `https://miguel92d.github.io/GastosSimple/privacy.html`
  - Recommended public path: `https://miguel92d.github.io/simple-app-ar/privacy.html`
- No `simple-app-ar` reference was found in the audited source/docs.
- No Play Store draft/checklist file was found in the repository by filename search for `play`, `store`, `checklist`, or `draft` outside generated build output.

## 6. Risky rename areas to avoid

- Do not rename the repository folder `GastosSimple`.
- Do not rename Android package/applicationId/namespace.
- Do not rename Kotlin package folders under `android/app/src/main/kotlin/com/migueld/gastossimple`.
- Do not rename iOS bundle identifiers.
- Do not change Firebase project ids or generated Firebase option values.
- Do not change `pubspec.yaml` package name or Dart `package:gastos_simple` imports in the branding cleanup.
- Do not change billing product ids, purchase entitlement names, or `simple_pro_lifetime`.
- Do not edit generated build output as a source of truth.
- Do not use `$` in technical identifiers, package names, product ids, schemes, app groups, paths, or bundle ids.

## 7. Recommended safe branding cleanup plan

1. Update only public web/PWA metadata:
   - `web/index.html`
   - `web/manifest.json`
2. Update the public GitHub Pages privacy URL in:
   - `lib/features/settings/screens/privacy_policy_screen.dart`
3. If the GitHub Pages repo/path has moved, publish the landing/privacy pages under `simple-app-ar` and verify the new URL works.
4. Decide whether `README.md` is public product documentation or developer-only documentation.
   - Public: rewrite visible heading/copy around `$imple`.
   - Developer-only: keep `gastos_simple` as technical package/repo naming and explicitly state public brand is `$imple`.
5. Leave all app ids, package names, Firebase ids, generated files, and billing identifiers untouched.

## 8. Exact next safe action

Make a small branding-only patch to `web/index.html`, `web/manifest.json`, and `lib/features/settings/screens/privacy_policy_screen.dart`, then search again for public `GastosSimple`, `Gastos Simple`, `gastos_simple`, and old GitHub Pages paths outside technical identifiers and generated output.
