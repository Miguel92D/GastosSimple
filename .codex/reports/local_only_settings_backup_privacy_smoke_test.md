# Local-Only Settings Backup Privacy Smoke Test

## 1. Executive summary
Focused runtime smoke testing completed for the local-only Settings flow on the updated debug app. The app launched, Settings opened, Backup opened, local export/import entry points responded through Android local share/file-picker surfaces, Privacy Policy opened, and normal Settings/Backup UI did not expose Google sign-in, cloud backup, or cloud restore entry points.

## 2. Target device used
Samsung SM G990E, device id `R5CW51JJ10N`, package `com.migueld.gastossimple`, debug build installed with `versionName=1.1.0`, `versionCode=3`, `lastUpdateTime=2026-05-12 08:36:12`.

## 3. Did app launch successfully
Yes. The installed debug app was force-stopped and relaunched with `adb shell am start -n com.migueld.gastossimple/.MainActivity`. `dumpsys window` confirmed focus on `com.migueld.gastossimple/.MainActivity`, and `pidof` returned a running app process.

## 4. Settings result
Passed. Settings opened from the drawer and showed expected local-first settings: language, security, local backup, currency, and legal/privacy. The visible Settings surfaces did not show Google account, sign-in, cloud backup, or cloud restore controls.

## 5. Backup result
Passed for local-only smoke scope. `Respaldo Local` opened `Backup de datos`. The screen showed only local backup copy plus `Crear Backup` and `Restaurar Backup`.

- `Crear Backup` opened the Android share sheet with one file, `gastos_simple_backup.json`.
- `Restaurar Backup` opened the Android document picker in `Recientes`.
- No Google sign-in, cloud backup, or cloud restore button was visible on the Backup screen.

## 6. Privacy policy result
Passed. `Política de Privacidad` opened successfully and displayed local-only privacy language, including local device storage, no external server upload, no third-party sharing, and manual backup guidance.

## 7. Hidden auth/cloud entry points still hidden: yes / no
Yes. In the checked normal release UI flow, Settings and Backup did not expose Google account, Google sign-in, cloud backup, cloud restore, or auth navigation entry points.

## 8. First blocker, if any
None for this scope.

## 9. Whether the local-only Settings flow is trustworthy enough to continue
Yes. The local-only Settings, Backup, and Privacy surfaces are coherent enough to continue targeted release-preparation validation.

## 10. Exact next safe action
Continue with the next narrow runtime smoke area; keep any auth/cloud or Android release configuration work in a separate explicitly scoped pass.
