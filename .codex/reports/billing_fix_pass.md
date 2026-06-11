# Billing Fix Pass

Fix date: 2026-05-12

Scope: scoped billing/pro entitlement fix for the one-time `simple_pro_lifetime` PRO purchase flow. No signing work, AAB generation, auth/cloud changes, currency/calculation logic, Android release config changes, or broad refactors were performed.

## 1. Executive summary

The billing flow now has one coherent entitlement path: `AppState.isPro`.

Before this pass, purchase delivery wrote `SharedPreferences` key `is_pro` and updated `PremiumService`, while the actual drawer, dashboard styling, action gates, and most PRO feature checks read `AppState` or `ProService`. A real purchase could therefore be locally recorded without unlocking the actual PRO gates.

This pass made `AppState` the single runtime source of truth, added persisted entitlement loading, wired purchase/restored delivery into `AppState.setProEntitlement(true)`, made `ProService` and `PremiumService` delegate to `AppState`, and updated the Premium screen to render the real `ProductDetails` result from Google Play instead of the hard-coded price. Billing loading, unavailable, pending, error, purchase, and restore status are now surfaced in the Premium screen/snackbars.

## 2. Files modified

- `lib/core/state/app_state.dart`
- `lib/main.dart`
- `lib/services/purchase_service.dart`
- `lib/services/pro_service.dart`
- `lib/services/premium_service.dart`
- `lib/features/settings/screens/premium_screen.dart`
- `.codex/reports/billing_fix_pass.md`

## 3. Root cause

The app had three separate PRO concepts:

- `AppState.isPro`, used by drawer UI, dashboard styling, and most PRO gates.
- `ProService.isPro`, used by the Premium screen and some compatibility checks.
- `PremiumService.isPremium`, updated by the purchase delivery path.

`PurchaseService._deliverProduct()` did not update `AppState` or `ProService`, so the real entitlement did not reach the actual PRO feature gates.

## 4. Single entitlement source chosen

`AppState.isPro`.

Reason: it was already the state read by the highest-impact runtime gates: `ActionController`, `AppDrawer`, and `HomeScreen`. The fix keeps that existing architecture and makes legacy `ProService`/`PremiumService` delegate to it instead of introducing another entitlement model.

Persistence key: `SharedPreferences` key `is_pro`.

Startup load: `main()` now awaits `AppState.instance.loadProEntitlement()` before `runApp(...)`.

## 5. Exact billing flow fixes applied

- Added persisted PRO entitlement methods to `AppState`:
  - `loadProEntitlement()`
  - `setProEntitlement(bool value)`
- Updated app startup to load the persisted entitlement before providers are created.
- Converted `PurchaseService` to a `ChangeNotifier` so the Premium screen can react to billing state.
- Made `PurchaseService.init()` idempotent.
- Made the purchase stream subscription nullable and safe when billing is unavailable.
- Added canonical product id constant: `PurchaseService.proProductId = 'simple_pro_lifetime'`.
- Added `PurchaseService.proProduct` and `hasProProduct` helpers.
- Added billing state fields:
  - `initialized`
  - `isLoadingProducts`
  - `purchasePending`
  - `isRestoring`
  - `statusMessage`
  - `errorMessage`
- Kept the one-time product query scoped to `simple_pro_lifetime`.
- Kept purchase launch as `buyNonConsumable(...)`.
- Awaited `completePurchase(...)`.
- Purchase/restored delivery now calls `AppState.instance.setProEntitlement(true)`.
- Removed the purchase delivery dependency on `PremiumService`.
- Made `ProService.isPro` delegate to `AppState.instance.isPro`.
- Made `PremiumService.isPremium` and `setPremium(...)` delegate to `AppState`.
- Updated `PremiumScreen` to:
  - wait for `PurchaseService.init()`
  - listen to `PurchaseService`
  - read entitlement from `context.watch<AppState>().isPro`
  - render `ProductDetails.title`, `ProductDetails.price`, and description when available
  - show `No disponible` and a configuration status when the Play product is not returned
  - show billing status/error messages
  - avoid fake/test unlock behavior when product loading fails

## 6. Restore/recheck behavior after fix

- Manual restore still uses `PurchaseService.restorePurchases()`.
- App startup billing initialization calls `recheckOwnedPurchases()`, which uses the same restore/query path silently after the purchase stream subscription exists.
- Restored purchases now go through the same entitlement delivery path as new purchases.
- Owned `simple_pro_lifetime` purchase delivery sets `AppState.isPro = true` and persists `is_pro = true`.

This is coherent in code, but still needs an internal Play test track to prove the real owned-purchase restore path with the Play Console product.

## 7. Runtime sanity-check result

Passed for the narrow local debug scope.

- `dart format` completed on changed billing/pro files.
- `flutter analyze` completed after escalation. It reported only pre-existing unrelated warnings/infos after the billing-file findings were fixed.
- `flutter build apk --debug --no-pub` passed.
- Installed rebuilt debug APK on Samsung SM G990E, device id `R5CW51JJ10N`: passed.
- App launched and focused `com.migueld.gastossimple/.MainActivity`: passed.
- Drawer showed `Cuenta Gratuita`, confirming the normal runtime remained locked/free.
- Tapping a PRO drawer feature opened the PRO upsell instead of the feature, confirming the locked gate used the unified entitlement.
- Premium screen opened from the upsell: passed.
- Premium screen showed `Acceso PRO`, `No disponible`, `El producto PRO no esta configurado en Play.`, `ACTIVAR PRO`, and `Restaurar compra`.

Interpretation: in a sideloaded debug build without an internal Play track product response, the screen now surfaces the real missing-product state and does not fake-unlock PRO. A real purchase was not attempted.

## 8. Remaining billing risk, if any

- The real `simple_pro_lifetime` product still must be created/activated in Play Console and verified on an internal test track.
- The current implementation trusts client-side `PurchaseDetails`; no server-side receipt validation exists.
- Billing Library is still 7.1.1 via `in_app_purchase_android 0.4.0+8`; it is publishable until August 31, 2026, but Billing Library 8 should be planned.
- Manual and startup restore/recheck are coherent in code but not proven with an actual owned purchase.
- The app still needs a signed/internal-test build before validating real purchase, restore, pending, cancel, and error flows.

## 9. Exact next safe action

Create/activate the one-time in-app product `simple_pro_lifetime` in Play Console, then generate a signed internal-test build and run a real billing smoke test covering product load, purchase, app restart entitlement persistence, restore after local data clear/reinstall, and canceled purchase.
