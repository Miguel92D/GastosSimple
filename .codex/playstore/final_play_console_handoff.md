# Final Play Console handoff

## 1. Executive summary

This handoff is for the exact signed AAB already generated and inspected for `$imple`. The app is ready for Play Console setup/internal testing preparation, with final manual choices still required in the Data Safety form and billing product setup.

Do not upload a different AAB without repeating artifact inspection.

## 2. AAB path to upload

`build/app/outputs/bundle/release/app-release.aab`

Artifact details:

- Package: `com.migueld.gastossimple`
- Version: `1.1.0`
- Version code: `3`
- App label: `$imple`
- minSdk: `24`
- targetSdk: `36`
- Signed and verified in `.codex/reports/signed_aab_generation_pass_3.md`
- Artifact inspected in `.codex/reports/signed_aab_artifact_inspection.md`

## 3. Privacy policy URL

`https://simple-app-ar.github.io/privacy.html`

Use this URL in Play Console app content / privacy policy fields.

## 4. Confirmed SDK posture

Confirmed included from the signed AAB:

- Firebase Core.
- Firebase Crashlytics.
- Firebase Sessions / Installations / DataTransport support for Crashlytics.
- Google Play Billing `7.1.1`.
- Local auth / biometric support.
- Notifications support.
- Share/file picker support.
- URL launcher support.
- Home widget / quick-entry deep link support.

Confirmed absent from signed AAB checks:

- Firebase Auth.
- Cloud Firestore.
- Google Sign-In.
- Firebase Analytics app SDK.

Nuance:

- `firebase-measurement-connector` appears transitively, but Firebase Analytics is not included.
- `play-services-location` appears transitively, but no location permission is declared.

## 5. Store setup steps

1. Open Play Console for package `com.migueld.gastossimple`.
2. Confirm app name/listing uses `$imple`.
3. Set privacy policy URL to `https://simple-app-ar.github.io/privacy.html`.
4. Complete App Content sections before production submission:
   - Privacy policy.
   - Data Safety.
   - Ads: no, unless you add ads later.
   - App access: no login/account required.
   - Target audience/content rating per app category.
5. Create or open an Internal Testing track.
6. Upload `build/app/outputs/bundle/release/app-release.aab`.
7. Add release notes suitable for testers.
8. Do not promote beyond internal testing until billing and Data Safety are verified.

## 6. Internal testing steps

1. Create an internal testing release.
2. Upload the signed AAB.
3. Add at least one internal tester email/list.
4. Add the same account as a license tester if it will test purchases.
5. Publish/roll out the internal testing release.
6. Wait until the Play Store test link is available.
7. Install from the Play Store internal testing link, not by sideloading.
8. Open `$imple`.
9. Confirm normal free state.
10. Open Premium screen.
11. Confirm `simple_pro_lifetime` product loads and displays localized Play price.
12. Test successful purchase.
13. Restart app and confirm PRO persistence.
14. Clear app data or reinstall, then test restore/recheck.
15. Test purchase cancel/error path with an account that does not complete purchase.
16. Test notification permission behavior on Android 13+.

## 7. Billing product setup steps

Product:

- Type: one-time in-app product / managed product.
- Product ID: `simple_pro_lifetime`
- Status: active before internal test purchase.

Setup:

1. Go to Play Console Monetize / Products / In-app products.
2. Create `simple_pro_lifetime` exactly.
3. Configure localized title, description, and price.
4. Activate the product.
5. Ensure the app release with Billing permission is on an internal test track.
6. Add tester account to internal testing.
7. Add tester account under license testing.
8. Test product load, purchase, cancel, restart persistence, and restore.

## 8. Data Safety areas to fill

Top-level:

- App collects or shares user data: yes.
- Encryption in transit: yes for Firebase/Google SDK transmissions.
- Account deletion: no app account is offered; users can delete local records, clear app data, or uninstall.
- Independent security review: no, unless one has been completed outside this repo.

Data types likely needed:

- App info and performance:
  - Crash logs.
  - Diagnostics.
- Device or other IDs:
  - Crashlytics/Firebase installation/session identifiers.
- Financial info:
  - Purchase history for Google Play Billing.
- Files and docs and/or Financial info:
  - user-initiated local backup export/import if Play Console classifies sharing/export this way.

Do not claim:

- Firebase Analytics/app activity collection.
- Firebase Auth/account data.
- Firestore/cloud backup.
- Google Sign-In.
- Location collection.
- Contacts/photos/audio/calendar/health/messages collection.
- Developer server upload of financial records.

## 9. Manual decisions still required

- Exact Play Console category for Google Play Billing purchase handling.
- Whether payment info should be left unselected because payment method details are handled by Google Play.
- Whether user-initiated backup export/import should be marked as `Files and docs`, `Financial info`, or both.
- Whether user-initiated export to another app is treated as sharing in the specific Play Console UI wording.
- Whether Crashlytics diagnostics are marked required or optional; current posture implies required while automatic collection is enabled.
- Confirm `simple_pro_lifetime` is active and visible to internal testers.
- Confirm notification permission behavior during Android 13+ internal testing.

## 10. Exact next safe action

In Play Console, complete Data Safety from `.codex/playstore/data_safety_final_draft.md`, configure `simple_pro_lifetime`, upload `build/app/outputs/bundle/release/app-release.aab` to Internal Testing, and run `.codex/playstore/internal_testing_billing_checklist.md`.
