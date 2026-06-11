# Internal testing billing checklist

## Scope

Use this checklist only with the signed AAB:

`build/app/outputs/bundle/release/app-release.aab`

Billing product:

`simple_pro_lifetime`

## Play Console setup

- [ ] Open Play Console for `com.migueld.gastossimple`.
- [ ] Confirm app listing name is `$imple`.
- [ ] Confirm privacy policy URL is `https://simple-app-ar.github.io/privacy.html`.
- [ ] Create or open Internal Testing track.
- [ ] Upload `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Add internal tester email/list.
- [ ] Add purchase tester under license testing.
- [ ] Publish/roll out the internal testing release.
- [ ] Wait for the internal test link to become available.

## Product setup

- [ ] Create one-time in-app product / managed product.
- [ ] Product ID is exactly `simple_pro_lifetime`.
- [ ] Product title and description are user-facing and localized as needed.
- [ ] Price is configured.
- [ ] Product is active.
- [ ] Product is available to the uploaded internal testing release.

## Install setup

- [ ] Tester joins through the Play Store internal test link.
- [ ] Tester installs from Play Store, not sideload.
- [ ] Tester account is the same account configured for license testing.
- [ ] Existing sideloaded builds are uninstalled if product loading behaves inconsistently.

## Product load test

- [ ] Launch `$imple`.
- [ ] Confirm free state appears.
- [ ] Open Premium screen.
- [ ] Confirm the product card shows `Acceso PRO`.
- [ ] Confirm Play localized price appears.
- [ ] Confirm no fake hardcoded price appears.
- [ ] Confirm fallback state is not shown once product is returned by Play.

## Successful purchase test

- [ ] Tap activate PRO.
- [ ] Confirm Google Play purchase sheet opens.
- [ ] Complete test purchase.
- [ ] Confirm app shows purchase success status.
- [ ] Confirm PRO gates unlock.
- [ ] Confirm drawer/status reflects PRO entitlement.

## Cancel/error test

- [ ] Start purchase with a tester path that cancels before completion.
- [ ] Confirm app remains free.
- [ ] Confirm app shows coherent cancel/error state.
- [ ] Confirm no fake unlock occurs.

## Restart persistence test

- [ ] Force close app after successful purchase.
- [ ] Relaunch app.
- [ ] Confirm PRO entitlement remains active.
- [ ] Confirm gated PRO features remain available.

## Restore/recheck test

- [ ] Clear app data or reinstall from internal test track.
- [ ] Open app.
- [ ] Use restore purchase.
- [ ] Confirm owned `simple_pro_lifetime` restores.
- [ ] Confirm `AppState.isPro` entitlement becomes active.
- [ ] Confirm restart after restore keeps PRO active.

## Pending purchase test, if available

- [ ] Use a Play test payment method that creates pending purchase if available.
- [ ] Confirm app shows pending status.
- [ ] Confirm app does not unlock PRO before purchase is completed.
- [ ] Complete or cancel pending purchase and verify final entitlement state.

## Regression checks

- [ ] Privacy policy link opens `https://simple-app-ar.github.io/privacy.html`.
- [ ] Android 13+ notification permission behavior is coherent.
- [ ] Local backup/export/import still works.
- [ ] No sign-in, Google account, cloud backup, or cloud restore controls are visible.

## Exact next safe action

After all checks pass, keep the AAB on Internal Testing while completing final Play Console Data Safety/manual review decisions before any broader rollout.
