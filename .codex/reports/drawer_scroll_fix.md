# Drawer Scroll Fix

## 1. Executive summary
Fixed the drawer bottom clipping issue with a minimal layout change. The side drawer list now includes device bottom safe-area padding, allowing the menu to scroll fully above the Android navigation bar. A focused device smoke check confirmed `Ajustes` is fully visible and tappable.

## 2. Files modified
- `lib/core/ui/app_drawer.dart`
- `.codex/reports/drawer_scroll_fix.md`

## 3. Root cause
The drawer combines a fixed-height header with an expanded scrollable menu. The menu `ListView` used only a fixed `16` bottom padding while the drawer extended behind the Android system navigation bar. On the target device, the final row landed partly inside the navigation bar area, so `Ajustes` was clipped and hard to tap.

## 4. Exact fix applied
Added bottom inset-aware padding to the drawer `ListView`:

- Reads `MediaQuery.of(context).viewPadding.bottom`.
- Keeps the existing left, top, right, and base bottom spacing.
- Adds the device bottom safe-area padding to the list bottom padding.
- Leaves the drawer header, menu items, navigation callbacks, and visual styling unchanged.

## 5. Drawer smoke-check results
Passed on Samsung SM G990E, device id `R5CW51JJ10N`.

- Built a refreshed debug APK and installed it on the device.
- Launched `com.migueld.gastossimple/.MainActivity`.
- Opened the drawer from the dashboard.
- Scrolled to the bottom.
- Verified `Ajustes` bounds were `[36,1992][876,2148]`, fully above the Android navigation bar beginning at `y=2196`.
- Tapped `Ajustes` from that fully visible position.
- Settings opened successfully.

Note: the first sandboxed Flutter build attempts timed out without refreshing the APK. One approved escalated Flutter debug build completed successfully and was used for the smoke check.

## 6. Remaining risk, if any
Low. This was validated on the current working Android device. Other screen sizes should benefit from the same safe-area padding, but should still be covered during normal multi-device smoke testing.

## 7. Exact next safe action
Continue with the next narrow runtime smoke area; keep any broader drawer redesign or menu reorganization out of this pass.
