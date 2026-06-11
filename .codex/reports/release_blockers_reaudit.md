# Release Blockers Re-audit

Audit date: 2026-05-12

Scope: audit-only re-evaluation after the recent runtime, currency, drawer, premium, and local-only fixes. No application source, business logic, Android release config, signing material, or release build settings were modified in this pass.

Skills applied: proyecto-orquestador-app-gastos, seguridad-android-play, auditor-dependencias-flutter.

## 1. Executive summary

The app is materially closer to a first Play Store release than it was in the original audits. The biggest product/policy decision has already been made and applied: first release is local-only. Normal Settings and Backup flows no longer expose Google sign-in, cloud backup, cloud restore, or `/auth` navigation. Premium test unlock paths have been removed from normal UI. Drawer and Premium screen clipping issues were fixed and smoke-tested. Quick-entry save, large amount save, and several runtime flows were validated on a physical Android device.

The true remaining path to Play Store is now narrower, but still blocked. The current release cannot honestly be submitted yet because privacy copy still says no external servers/third parties while `main.dart` initializes Firebase and logs Analytics/Crashlytics at startup. Data safety declarations are still required for active SDKs and user-visible local export/share/import behavior. Release signing still falls back to debug signing when `key.properties` is missing, and no signed release AAB has been generated and validated. Automated test/analyzer confidence remains stale because Dart/Flutter validation has repeatedly timed out, although manual runtime confidence is much better than before.

Updated release readiness: 68/100.

## 2. Original blockers re-evaluated one by one

1. Privacy policy mismatch.
   Status: partially fixed.
   Re-evaluation: The local-only product behavior is now much closer to the in-app privacy promise for financial data. Settings and Backup expose only local backup/import/export, and the smoke test confirmed no visible cloud/auth controls in normal release UI. However, `lib/main.dart` still calls `Firebase.initializeApp`, registers Crashlytics fatal/nonfatal handlers, and logs `FirebaseAnalytics.instance.logAppOpen()`. The current privacy text still says no external upload, no third-party sharing, and no tracking behavior. That remains too broad for a build with active Analytics/Crashlytics.

2. Missing account deletion path.
   Status: no longer applicable for the first local-only release, with a residual latent-code risk.
   Re-evaluation: Because Google sign-in/account creation is no longer exposed through normal Settings/Backup/routing, account deletion should not be required for the first local-only release path. If auth is re-exposed later, account deletion and cloud data deletion become blockers again.

3. Cloud restore incomplete.
   Status: no longer applicable for the first local-only release.
   Re-evaluation: Cloud backup/restore controls are hidden from normal release UX, automatic cloud backup calls were removed from transaction changes, and Backup now exposes local export/import only. `CloudBackupService` remains incomplete in source, but it is not on the normal first-release path.

4. Premium test unlock fallback.
   Status: fully fixed for normal tested UI paths.
   Re-evaluation: Reports confirm the fallback local unlock, Settings beta switch, drawer free/pro test toggle, and default-true premium state were removed. Runtime smoke verified Settings/Premium no longer expose unsafe premium shortcuts. Store-side billing setup and product availability still need release validation, but the original unsafe test unlock blocker is fixed.

5. Release signing not ready.
   Status: still open.
   Re-evaluation: `android/app/build.gradle` still signs release with debug signing when `android/key.properties` is missing. No release keystore/key properties were found in the prior audit, and this pass found no report proving a signed release AAB was produced.

6. Release build/App Bundle unverified.
   Status: still open.
   Re-evaluation: Debug builds and runtime smokes have improved confidence, but there is still no verified `flutter build appbundle --release` result, no release install/smoke, and no final merged manifest review from a release build.

7. Data safety declarations not prepared.
   Status: still open.
   Re-evaluation: The first release is local-only for financial data, but Data safety still must cover active SDK behavior and app behavior: Firebase Analytics, Crashlytics, billing, notifications, local auth/biometrics, file picker, share/export/import, URL launcher, and any Firebase/Auth/Firestore/Google Sign-In dependencies left in the shipped app.

8. Financial type/currency consistency.
   Status: partially fixed.
   Re-evaluation: Canonical types `ingreso`/`gasto`, legacy normalization, database aggregate compatibility, and parser/formatter rules were implemented. Quick-entry income/expense saves were validated on device and stored canonical types. Large movement/debt/goal/budget amounts were also validated. Remaining gap: Dart format/analyze still timed out and the broader currency checklist is not fully automated or fully complete.

9. Tests stale and not representative.
   Status: still open, but less blocking than before because manual runtime smoke coverage improved.
   Re-evaluation: `test/widget_test.dart` still expects `Gastos Simple`, while app title/branding now use `$imple` and Firebase/app startup can make widget tests fragile without mocks. Manual smoke tests now cover launch, Settings, Backup, Privacy, Premium, drawer, quick-entry save, and large amounts, but automated regression protection remains weak.

10. Dirty/mixed repo state.
    Status: partially fixed as a release-risk category.
    Re-evaluation: Several targeted fixes and reports have clarified intent, but the repo still contains broad source changes and latent auth/cloud files. This is no longer the top release blocker, but it remains a risk until the final release diff is reviewed intentionally.

11. Hidden auth/cloud code creates Play risk.
    Status: partially fixed.
    Re-evaluation: Hidden auth/cloud code is low risk from a user-flow/account-deletion perspective because it is not routed or exposed. It is still a Play/Data safety risk if the dependencies and initialized SDKs remain in the shipped artifact. Firestore/Auth/Google Sign-In source files also make future regressions easy if routes/settings entries are reintroduced accidentally.

12. Drawer and Premium layout/runtime blockers.
    Status: fully fixed for the tested device.
    Re-evaluation: Drawer safe-area padding and Premium scroll padding/badge removal were implemented and smoke-tested on Samsung SM G990E. Normal multi-device smoke should still happen, but these are no longer current Play blockers.

## 3. Fixed blockers

- Premium test unlock behavior removed from normal UI paths.
- Settings beta premium switch removed.
- Drawer free/pro test toggle removed.
- Premium default state no longer starts as premium before secure storage load.
- Normal Settings/Backup release path no longer exposes Google account, Google sign-in, cloud backup, or cloud restore.
- `/auth` route no longer exists in the app router for normal release navigation.
- Transaction changes no longer trigger automatic cloud backup.
- Drawer bottom clipping fixed and smoke-tested.
- Premium bottom CTA clipping fixed and smoke-tested.
- Misleading `MEJOR VALOR` badge removed from the single Premium plan.
- Quick-entry income/expense save path now stores canonical transaction types and updates dashboard totals in the tested flow.
- Large amount save/persistence/display validated for movement, debt, goal, and budget.

## 4. Partially fixed blockers

- Privacy policy alignment: financial cloud behavior is now local-only in visible flows, but Analytics/Crashlytics still make the "no external servers/third parties/no tracking" language inaccurate.
- Hidden auth/cloud risk: not exposed to users, but source files and dependencies remain.
- Currency/financial consistency: fixed in code direction and validated in key runtime flows, but Dart format/analyze and the full checklist remain incomplete.
- Runtime confidence: much better after physical-device smokes, but not yet a full release smoke matrix.
- Dirty repo risk: improved by scoped reports and targeted fixes, but still needs a final intentional release diff review.
- Premium purchase readiness: unsafe fallback fixed, but Play product configuration and a non-purchasing billing review remain unproven.

## 5. Still-open blockers

- Privacy policy and external privacy URL must be aligned with the actual shipped build, especially Firebase Analytics/Crashlytics and local export/share/import behavior.
- Play Data safety answers must be prepared from the actual dependency set and SDK behavior.
- Release signing is not ready; release config still falls back to debug signing when `key.properties` is absent.
- Signed release AAB has not been generated or smoke-tested.
- Release merged manifest has not been reviewed for plugin-merged permissions.
- Automated validation is stale: widget tests are likely outdated and Dart/Flutter analyzer/formatter validation has timed out repeatedly.
- Store-side billing/product setup for `simple_pro_lifetime` remains unverified.
- Firebase API restrictions and console-side configuration still need a release pass if Firebase remains in the shipped build.

## 6. No-longer-applicable blockers for first local-only release

- Account deletion flow, as long as Google sign-in/account creation remains hidden and unreachable in the shipped app.
- Cloud restore implementation, as long as cloud backup/restore remains hidden and unreachable in the shipped app.
- Cloud data deletion flow, as long as no cloud account/backup feature ships.
- Firestore financial backup behavior as a user-facing first-release feature, as long as no UI or automatic path uploads financial records.

These become blockers again immediately if Google sign-in, Firebase account creation, cloud backup, cloud restore, or automatic cloud upload are reintroduced before release.

## 7. Updated release readiness score

68/100.

Reasoning:

- Product/runtime readiness improved substantially after local-only, premium, drawer, quick-entry, currency, and large-amount validations.
- Policy readiness is still incomplete because privacy/Data safety do not yet match active SDK behavior.
- Release-process readiness is still blocked by signing, signed AAB generation, merged-manifest review, and final Play Console declarations.
- Test confidence is better manually but still weak automatically.

## 8. Exact safest next action

Run a focused privacy/Data safety dependency pass before signing work: decide whether the first local-only release will ship Firebase Analytics/Crashlytics/Auth/Firestore/Google Sign-In dependencies at all. For the safest local-only path, remove or disable unused auth/cloud SDK behavior from the release artifact and update the in-app and hosted privacy policy to match the exact shipped behavior; then prepare Data safety answers from the final dependency set. Only after that should release signing and signed AAB generation start.
