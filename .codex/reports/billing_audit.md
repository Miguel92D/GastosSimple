# Billing Audit

Audit date: 2026-05-12

Scope: audit-only review of the current Google Play Billing implementation for the planned PRO in-app purchase flow. No application source, business logic, Android release config, signing, AAB generation, or fixes were performed.

References read first:

- `.codex/reports/analytics_crashlytics_posture_pass.md`
- `.codex/reports/premium_fallback_fix.md`
- `.codex/reports/settings_premium_smoke_test.md`
- `.codex/reports/release_blockers_reaudit.md`

External policy/version reference checked: Google Play Billing Library deprecation FAQ, last updated 2026-02-26, which lists Billing Library 7 publishable for new apps/updates until August 31, 2026 and Billing Library 8 until August 31, 2027.

## 1. Executive summary

The app has a real Google Play Billing integration skeleton, not just a fake premium button. It uses `in_app_purchase`, queries the product id `simple_pro_lifetime`, launches `buyNonConsumable`, listens to `purchaseStream`, handles purchased/restored statuses, completes pending purchases, and exposes a restore button on the Premium screen.

However, the implementation is not release-ready. The product posture is one-time/non-consumable, but product loading is fragile, the UI uses a hard-coded price instead of store `ProductDetails`, purchase result handling has no receipt/server verification, pending/error states are not surfaced to the user, and restore is manual only. The biggest blocker is entitlement: purchase delivery writes `SharedPreferences` key `is_pro` and calls `PremiumService.instance.setPremium(true)`, while the visible PRO gates mostly read `AppState.instance.isPro` or `ProService.instance.isPro`. Those are not updated by the purchase delivery path and are not loaded from the persisted purchase flag. As written, a successful purchase can be recorded locally without consistently unlocking the actual PRO UI.

Conclusion: billing dependency/status is present and broadly coherent for Play release preparation, but the purchase and entitlement flow is partial and must be fixed and tested before signing/release submission.

## 2. Billing dependency/status found

- Direct Flutter dependency: `in_app_purchase: ^3.2.0` in `pubspec.yaml`.
- Resolved Flutter dependency: `in_app_purchase` `3.2.3` in `pubspec.lock`.
- Resolved Android plugin: `in_app_purchase_android` `0.4.0+8`.
- Resolved iOS plugin: `in_app_purchase_storekit` `0.4.8+1`.
- Local plugin Gradle file embeds `com.android.billingclient:billing:7.1.1`.
- Current debug APK manifest contains `com.android.vending.BILLING`, `com.google.android.play.billingclient.version`, `ProxyBillingActivity`, and `ProxyBillingActivityV2`.
- Android ProGuard rules keep `com.android.vending.billing.**`.

Status: present and usable, but not ideal long-term. Billing Library 7.1.1 is still within the official publishable window until August 31, 2026, but Billing Library 8 is the safer forward-looking target before the v7 deprecation date.

## 3. Product type posture found

Product type found: one-time.

Evidence:

- `PurchaseService.loadProducts()` queries only `simple_pro_lifetime`.
- `PurchaseService.buyProduct()` calls `_iap.buyNonConsumable(...)` for `simple_pro_lifetime`.
- Premium UI copy says lifetime/one-time: `lifetime_price` is `$4.99 one-time` / `$4.99 pago único`.
- No subscription product id, subscription purchase call, base plan, offer token, or subscription-specific handling was found.

Risk: the price displayed in the app is hard-coded from localization, not taken from `ProductDetails.price`, so it can drift from the Play Console price and local currency formatting.

## 4. Purchase flow status

Status: partial.

Already present:

- App startup calls `PurchaseService.instance.init()` inside `_initializeServices()`.
- `init()` checks `_iap.isAvailable()`.
- If available, `loadProducts()` queries `simple_pro_lifetime`.
- If available, `init()` subscribes to `_iap.purchaseStream`.
- Premium screen button searches `PurchaseService.instance.products` for selected product id.
- If product exists, Premium screen calls `PurchaseService.instance.buyProduct(product)`.
- Purchase launch uses `buyNonConsumable`.
- Missing product no longer unlocks PRO; it shows a non-unlocking snackbar.

Incomplete/risky:

- Premium screen does not call or await `loadProducts()`; it relies on app startup initialization racing ahead of the user.
- `_isLoading` on Premium screen is set to false immediately and does not represent billing/product loading.
- If product query is delayed or failed, the user only sees "La compra no esta disponible por ahora."
- Product query errors are not surfaced to UI.
- Pending purchases are not shown to the user.
- Purchase errors are only `debugPrint`.
- `completePurchase(purchaseDetails)` is called without `await`.
- No purchase verification is performed before local entitlement grant.
- No clear release smoke has proven that Play Console product `simple_pro_lifetime` exists, is active, and is returned for the signed app/package.

## 5. Entitlement/pro unlock status

Status: broken for release confidence.

Already present:

- `_deliverProduct()` detects `purchaseDetails.productID == 'simple_pro_lifetime'`.
- It writes `SharedPreferences` key `is_pro = true`.
- It calls `PremiumService.instance.setPremium(true)`, which writes secure storage key `is_premium = true`.

Blocking mismatch:

- The main drawer/account state reads `context.watch<AppState>().isPro`.
- `ActionController` gates PRO features with `AppState.instance.isPro`.
- `HomeScreen` PRO title styling reads `context.watch<AppState>().isPro`.
- `PremiumScreen` decides whether to show purchase controls with `ProService.instance.isPro`.
- `ProFeature` checks `AppState.instance.isPro || ProService.instance.isPro`.
- Purchase delivery does not call `AppState.instance.setPro(true)`.
- Purchase delivery does not call `ProService.instance.activatePro()`.
- `SharedPreferences` key `is_pro` is written but no current code path was found that reads it back into `AppState` or `ProService`.
- `PremiumService` is not registered as a provider in `main.dart`, and its `isPremium` state is not the primary state read by the visible PRO gates.

Effect: a successful purchase/restored purchase can update `PremiumService` and a stored flag while the visible PRO gates remain free/locked. This is a release blocker for paid PRO.

## 6. Restore/recheck purchase status

Status: partial.

Already present:

- Premium screen has a `restore_purchase` button.
- `_restorePurchase()` calls `PurchaseService.instance.restorePurchases()`.
- Restored purchases go through the same `_deliverProduct()` path as purchased purchases.

Incomplete/risky:

- Restore result is not surfaced to the user.
- Restore failure is only `debugPrint`.
- No startup recheck/reconciliation of owned purchases was found.
- Local entitlement persistence is split across `SharedPreferences` and secure storage, but the main gates do not load either into `AppState`/`ProService`.
- If the app is reinstalled or local storage is cleared, entitlement depends on manual restore and the same broken unlock-state bridge.

## 7. Billing-specific release blockers

1. Entitlement bridge is broken: purchase/restored delivery does not update the state objects that most PRO gates actually read.
2. No verified Play Console product setup: `simple_pro_lifetime` must exist as an active one-time in-app product for package `com.migueld.gastossimple`.
3. Product loading UX is incomplete: Premium screen does not reflect billing availability, loading, missing product, pending purchase, or purchase error states.
4. Price is hard-coded in localization instead of displayed from Play `ProductDetails.price`.
5. Purchase verification is absent; local entitlement is granted directly from client-side `PurchaseDetails`.
6. Restore is manual and silent; no startup ownership reconciliation exists.
7. Billing Library 7.1.1 is publishable for now but close enough to its August 31, 2026 cutoff that a Billing Library 8 upgrade should be planned before or soon after release.
8. `PurchaseService.dispose()` can cancel an uninitialized `late` subscription if called when billing was unavailable, though no current caller was found.

## 8. Exact safest next action

Before signing or generating a release AAB, do a scoped billing fix pass that makes one canonical PRO entitlement source and wires purchase/restored delivery into the same state used by all PRO gates. In the same pass, make the Premium screen load/display real `ProductDetails`, surface unavailable/pending/error/restore states, and then run an internal-test-track billing smoke with Play Console product `simple_pro_lifetime`.
