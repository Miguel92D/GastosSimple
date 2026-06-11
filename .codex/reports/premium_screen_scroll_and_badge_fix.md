# Premium Screen Scroll And Badge Fix

## 1. Executive summary
Fixed the two requested Premium/PRO screen UX issues with a narrow layout/content change. The single one-time payment plan no longer shows the misleading `MEJOR VALOR` badge, and the scroll view now has enough bottom padding for the Android navigation bar and the app's floating menu button so the bottom CTA area can scroll fully into view.

## 2. Files modified
- `lib/features/settings/screens/premium_screen.dart`
- `.codex/reports/premium_screen_scroll_and_badge_fix.md`

## 3. Root cause
The Premium screen used a fixed `24` pixel padding around the `SingleChildScrollView` content. On the target device, the bottom plan/CTA area could land behind the Android navigation bar and the app's center floating menu button.

The `MEJOR VALOR` badge was enabled by passing `isRecommended: true` to the only available lifetime plan. Because there is no tier comparison, that label was misleading for a one-time payment product.

## 4. Exact fix applied
- Replaced fixed all-sides padding with `EdgeInsets.fromLTRB(...)`.
- Added `MediaQuery.of(context).viewPadding.bottom` plus extra space for the floating menu button to the bottom scroll padding.
- Removed the `isRecommended: true` flag from the lifetime plan card.
- Kept the existing one-time payment text: `Acceso PRO` and `$4.99 pago único`.
- Did not change purchase, restore, billing, auth/cloud, Android release config, currency, or calculation logic.

## 5. Smoke-check results
Passed on Samsung SM G990E, device id `R5CW51JJ10N`.

- Built and installed a refreshed debug APK.
- Launched `com.migueld.gastossimple/.MainActivity`.
- Opened Premium through the normal PRO gate.
- Verified the plan card displayed `Acceso PRO` and `$4.99 pago único` without `MEJOR VALOR`.
- Scrolled to the bottom.
- Verified `ACTIVAR PRO` bounds were `[72,1470][1008,1644]`.
- Verified `Restaurar compra` bounds were `[72,1692][1008,1836]`.
- Verified the Android navigation bar began at `y=2196`, so the bottom Premium content was fully visible above system UI.

Note: `dart format lib/features/settings/screens/premium_screen.dart` timed out in the workspace, matching the prior formatter/tooling behavior. The debug build succeeded using the same approved escalated Flutter build path used in the drawer fix pass.

## 6. Remaining risk, if any
Low. Runtime smoke passed on the current working Android device. Other device sizes should benefit from the bottom inset-aware padding, but normal multi-device smoke testing should still cover the Premium screen.

## 7. Exact next safe action
Continue with the next narrow runtime smoke area; leave broader Premium copy, pricing, billing configuration, and release work to separate explicitly scoped passes.
