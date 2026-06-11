# Root GitHub Pages privacy prep

## 1. Executive summary

Prepared the public privacy policy reference for a clean root GitHub Pages site under the `simple-app-ar` account. The in-app privacy button now points to `https://simple-app-ar.github.io/privacy.html`, avoiding the old `/GastosSimple/` path in the public policy URL.

A copyable root-site folder was prepared at `github_pages_root/` with the aligned public pages needed for the new `simple-app-ar.github.io` repository. Visible branding remains `$imple`; technical app identifiers were left unchanged.

## 2. Files modified

- `lib/features/settings/screens/privacy_policy_screen.dart`
- `github_pages_root/privacy.html`
- `github_pages_root/index.html`
- `.codex/reports/root_github_pages_privacy_prep.md`

## 3. Old URL references found

- Runtime/public app reference found and updated:
  - `lib/features/settings/screens/privacy_policy_screen.dart`
  - Old: `https://simple-app-ar.github.io/GastosSimple/privacy.html`
- Historical report references still exist in:
  - `.codex/reports/brand_naming_cleanup_pass.md`
  - These are audit history, not public app/runtime references.

## 4. New clean URL applied

- `https://simple-app-ar.github.io/privacy.html`

Applied in:

- `lib/features/settings/screens/privacy_policy_screen.dart`

## 5. Root GitHub Pages files prepared

- `github_pages_root/privacy.html`
  - Root privacy page ready to copy to the `simple-app-ar.github.io` repository root.
  - Uses visible `$imple` branding.
  - Contains no visible `GastosSimple` branding.
  - Uses external CDN styles/fonts already present in the existing privacy page; no local style assets are required.
- `github_pages_root/index.html`
  - Companion root page copied because `privacy.html` links back to `index.html`.
  - Keeps the public site internally navigable when copied to the root GitHub Pages repo.

## 6. Technical identifiers intentionally left unchanged

- Flutter package name: `gastos_simple`
- Dart imports using `package:gastos_simple/...`
- `GastosSimpleApp` and related class names
- Android package/application id/namespace: `com.migueld.gastossimple`
- Android deep link scheme: `gastossimple`
- iOS bundle identifiers
- Firebase project/config ids, including `simple-app-78147`
- Billing/product id: `simple_pro_lifetime`
- Current repository/folder names

## 7. Manual GitHub steps still required

- Create or use the GitHub account/organization `simple-app-ar`.
- Create a public repository named `simple-app-ar.github.io`.
- Copy the contents of `github_pages_root/` into the root of that repository.
- Commit and push to the default branch.
- In GitHub Pages settings, ensure the site is served from the repository root on the default branch if Pages is not enabled automatically.
- Open `https://simple-app-ar.github.io/privacy.html` and verify it resolves.
- After publishing, verify the in-app privacy button opens the clean URL.

## 8. Exact next safe action

Copy `github_pages_root/privacy.html` and `github_pages_root/index.html` into the root of the new `simple-app-ar.github.io` repository, push them, then verify `https://simple-app-ar.github.io/privacy.html` in a browser.
