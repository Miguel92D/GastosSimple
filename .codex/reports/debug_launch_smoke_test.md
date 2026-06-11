1. Executive summary

The app was run in debug mode on the connected Android device using the recovered Flutter wrapper context. Flutter invocation, install, and launch succeeded. The app reached the local-only dashboard/home flow without an immediate crash, basic navigation worked, settings opened, and auth/cloud entry points were not visible in the normal flow checked.

One focused runtime blocker was found: the quick-entry expense button opens the movement screen, but the screen shows income categories/defaults instead of expense categories/defaults.

2. Device/emulator detected

- Target used: SM G990E
- Device id: R5CW51JJ10N
- Platform: Android arm64
- Android version/API: Android 16 / API 36
- Other device state observed: emulator-5562 was listed as offline and was not used.

3. Command run

Temporary Flutter wrapper context used:

```powershell
$env:GIT_CONFIG_COUNT='1'
$env:GIT_CONFIG_KEY_0='safe.directory'
$env:GIT_CONFIG_VALUE_0='C:/flutter'
```

Debug run command:

```powershell
C:\flutter\bin\flutter.bat run -d R5CW51JJ10N --debug --no-pub
```

Captured logs:

- .codex/reports/debug_launch_smoke_flutter_run_stdout.log
- .codex/reports/debug_launch_smoke_flutter_run_stderr.log

4. Did the app launch successfully

Yes.

Evidence:

- Flutter built the debug APK.
- Flutter installed `build\app\outputs\flutter-apk\app-debug.apk`.
- `com.migueld.gastossimple/.MainActivity` became the focused app after dismissing the keyguard.
- The app process was present during smoke testing.
- The dashboard/home UI rendered with balance, month, income, expense, and recent movement content.

5. Smoke test results by area

- App startup: passed. The app launched on the device after unlock/keyguard dismissal.
- Dashboard/home load: passed. Dashboard content rendered, including monthly balance, income, expense, and recent movements.
- Navigation basic flow: passed. Quick-entry and dashboard/menu navigation worked. The drawer settings row initially sat near the Android navigation bar and required scrolling the drawer upward before tapping.
- Add income screen opens: passed. The quick-entry plus button opened `Nuevo movimiento` with income categories such as `SALARIO`, `INVERSIÓN`, `VENTA`, and `REGALO`.
- Add expense screen opens: partial failure. The quick-entry minus button opened `Nuevo movimiento`, but it showed the same income category set instead of expense categories/defaults.
- Settings screen opens: passed. Settings opened after scrolling the drawer upward.
- Auth/cloud entry points hidden from normal release flow: passed for the checked surfaces. Drawer/settings dumps did not expose Google sign-in, cloud backup, Firestore, or cloud restore entry points. Settings showed local backup text.
- No immediate crash in local-only flow: passed. No initial launch crash was observed while moving through dashboard, quick-entry, drawer, and settings.

6. First runtime blocker, if any

Quick-entry expense flow is miswired or missing type/default propagation. Tapping the expense/minus entry point opens the movement screen but presents income categories/defaults:

- `SALARIO`
- `INVERSIÓN`
- `VENTA`
- `REGALO`

Expected behavior for this smoke path is that the expense entry point opens the add movement screen in expense mode with expense categories/defaults. This is a source/runtime blocker for the add-expense smoke area, but it did not block app launch.

7. Whether the app is usable enough to continue

Yes. The app is launchable and usable enough to continue targeted validation, with the quick-entry expense mode bug fixed first.

8. Exact next safe action

Run a source-fix pass focused only on the quick-entry expense route/type/category default wiring, then rerun the same targeted launch smoke checks for the plus and minus entry points before continuing the currency validation checklist.
