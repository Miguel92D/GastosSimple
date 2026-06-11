# Premium Fallback Fix

## 1. Executive summary

Removed the reachable premium test unlock paths from normal app UI flows with a narrow premium-only change.

The app no longer grants premium when the Play product is unavailable, no longer exposes the Settings beta premium switch, and no longer exposes the drawer test toggle between free and premium modes.

No release signing, Android release config, auth/cloud, or currency/calculation logic was touched.

## 2. Files modified

- `lib/features/settings/screens/premium_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/core/ui/app_drawer.dart`
- `lib/services/premium_service.dart`
- `.codex/reports/premium_fallback_fix.md`

## 3. Root cause

Premium had multiple production-reachable shortcuts:

- `PremiumScreen._buyPremium()` called `PremiumService.instance.setPremium(true)` when the store product was missing.
- Settings exposed a `DEMO / TESTING` switch that called `AppState.instance.setPro()` and `ProService.instance.activatePro()`.
- The drawer exposed a test mode toggle that switched between free and premium modes.
- `PremiumService` defaulted `_isPremium` to `true` before secure storage finished loading.

## 4. Exact fix applied

- Removed the local premium grant fallback from `PremiumScreen._buyPremium()`.
- Replaced the fallback unlock behavior with a non-unlocking snackbar when the product is unavailable.
- Removed the Settings demo/testing premium switch.
- Removed the drawer free/premium test toggle.
- Changed `PremiumService` initial `_isPremium` value from `true` to `false`.

The legitimate purchase delivery path in `PurchaseService._deliverProduct()` was left intact.

## 5. User-visible behavior after fix

- Users can still open the Premium screen.
- If the Play product is available, the existing purchase call path remains active.
- If the Play product is not available, tapping activate shows a message instead of unlocking premium.
- Settings no longer shows the beta premium switch.
- The drawer no longer shows the test free/premium toggle.

## 6. Remaining premium risks, if any

- Debug build verification of the updated source was not completed because `flutter build apk --debug --no-pub` timed out after 300 seconds without compiler output.
- `dart format` on the touched files also timed out after 60 seconds without formatter output.
- Existing generated/localization keys such as `premium_test_unlocked`, `switch_to_free`, and `switch_to_pro` still exist but are no longer referenced from reachable premium UI paths touched in this pass.
- Premium state is still split between `PremiumService`, `ProService`, and `AppState`; this pass did not refactor that because the scope was only removing unsafe shortcuts.

Verification performed:

- Static search no longer finds the removed production UI calls to `AppState.instance.setPro(...)`, `ProService.instance.activatePro()`, or the fallback `PremiumService.instance.setPremium(true)` in the premium/settings/drawer UI files.
- The currently installed debug app still launches on `R5CW51JJ10N` and focuses `com.migueld.gastossimple/.MainActivity`; however, this installed APK was not proven to include the new source changes because the debug build timed out.

## 7. Exact next safe action

Diagnose the Flutter tooling/build timeout, then run one debug build/install smoke check to confirm the updated Premium screen and Settings UI on device.
