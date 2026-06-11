# Brand naming cleanup pass

## 1. Executive summary

Applied a small branding-only cleanup for public/user-facing surfaces identified as safe by the audit. Public web/PWA metadata now uses `$imple`, the default public README copy was replaced with `$imple` product-facing text plus a technical identifier note, and the in-app privacy policy button now points to the requested `simple-app-ar` GitHub Pages URL.

No package names, application ids, namespaces, bundle ids, Dart imports, class names, billing ids, release signing config, folders, or business logic were intentionally changed.

## 2. Files modified

- `web/index.html`
- `web/manifest.json`
- `lib/features/settings/screens/privacy_policy_screen.dart`
- `README.md`
- `.codex/reports/brand_naming_cleanup_pass.md`

## 3. Public-facing branding changes applied

- `web/index.html`
  - Changed public web description from default Flutter text to `$imple` product copy.
  - Changed Apple web app title from `gastos_simple` to `$imple`.
  - Changed browser title from `gastos_simple` to `$imple`.
- `web/manifest.json`
  - Changed PWA `name` from `gastos_simple` to `$imple`.
  - Changed PWA `short_name` from `gastos_simple` to `$imple`.
  - Changed PWA description from default Flutter text to `$imple` product copy.
- `README.md`
  - Replaced default Flutter template heading/copy with `$imple` public product wording.
  - Added a technical note that `gastos_simple` and similar identifiers are intentionally preserved.

## 4. Privacy URL changes applied

- `lib/features/settings/screens/privacy_policy_screen.dart`
  - Changed the online privacy policy URL to:
    `https://simple-app-ar.github.io/GastosSimple/privacy.html`

## 5. Technical identifiers intentionally left unchanged

- `pubspec.yaml` package name: `gastos_simple`
- Dart imports using `package:gastos_simple/...`
- `GastosSimpleApp` and related class names
- Android package/application id/namespace: `com.migueld.gastossimple`
- Android deep link scheme: `gastossimple`
- iOS bundle identifiers
- Firebase project/config identifiers, including `simple-app-78147`
- Billing/product id: `simple_pro_lifetime`
- Existing repo/folder/path names, including `GastosSimple`

## 6. Any remaining visible brand references needing manual review

- `README.md` intentionally mentions `gastos_simple` as a technical identifier note. This is not public branding, but should be kept only if the README remains partly developer-facing.
- `docs/index.html`, `docs/privacy.html`, `SimpleLanding/index.html`, and `SimpleLanding/privacy.html` already use `$imple`; their `$IMPLE APP` footer casing remains a manual style decision.
- The requested privacy URL intentionally keeps `/GastosSimple/privacy.html` in the path. This is treated as a URL/path reference, not visible app branding.

## 7. Exact next safe action

Run one final targeted search outside generated output for old public branding terms, then verify the GitHub Pages URL `https://simple-app-ar.github.io/GastosSimple/privacy.html` resolves after publishing.
