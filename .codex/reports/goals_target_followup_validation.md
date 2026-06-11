# Goals Target Follow-Up Validation

## 1. Executive summary

Validated goal target creation and edit/reopen preservation on the same physical device context used by the prior currency checks.

The primary case `1250.75` passed. The field interpreted it as `1.250,75`, saved it, displayed the goal as `$0 / $1,250.75`, and SQLite stored `target_amount = 1250.75`.

The secondary feasible case `1.250,75` also passed and stored `target_amount = 1250.75`.

No application source files, Android release config, auth/cloud files, or broad refactors were touched.

## 2. Target device used

- Device: `SM G990E`
- Device id: `R5CW51JJ10N`
- App package: `com.migueld.gastossimple`
- Installed app version: `versionName=1.1.0`, `versionCode=3`, `targetSdk=36`
- Debug context: existing installed debug app session on the same device context. A fresh `flutter run -d R5CW51JJ10N --debug --no-pub` start was attempted, but the spawned process exited before producing a usable log, so validation continued against the installed debug app.

## 3. Keyboard-safe save path used

Used the existing local test Premium switch from the drawer to access the gated goals screen.

For goal creation:

- Opened `Metas de ahorro`.
- Tapped the add-goal FAB.
- Entered the goal name.
- Entered the target amount.
- Kept the keyboard open.
- Scrolled the bottom-sheet content upward until the save button was visible.
- Tapped `Crear Meta` directly without tapping the backdrop or using a keyboard-dismiss gesture.

For edit/reopen:

- Tapped the edit action on the saved goal.
- Verified the target amount field value.
- Tapped `Guardar Cambios` without changing the amount.

## 4. Input interpretation result

Primary case:

- Input typed: `1250.75`
- Field interpretation observed: `1.250,75`

Secondary case:

- Input typed: `1.250,75`
- Field interpretation observed: `1.250,75`

## 5. Stored target_amount verification

SQLite database copied from the app sandbox and queried with `sqlite3.exe`.

Verified rows:

```text
1|auto|10000.0|12.5|2036-03-28T00:00:00.000
2|Goal125075|1250.75|0.0|2027-05-12T08:12:02.663778
3|GoalComma125075|1250.75|0.0|2027-05-12T08:17:22.082502
```

Result:

- `Goal125075.target_amount = 1250.75`
- `GoalComma125075.target_amount = 1250.75`

## 6. Visible goal display verification

Primary goal display observed after save:

```text
Goal125075
$0 / $1,250.75
```

Secondary goal was created successfully and became visible in the list as `GoalComma125075`; direct display amount was not separately scrolled into full view after database verification because the primary visible display requirement had already passed.

## 7. Edit/reopen preservation result

Passed.

Reopened `Goal125075` through edit. The amount field showed:

```text
1.250,75
```

Saving unchanged returned to the list with:

```text
Goal125075
$0 / $1,250.75
```

## 8. First blocker, if any

No validation blocker found.

Operational note: direct `adb input text` only populated the amount field after tapping the right side of the target `EditText`; tapping the prefix area did not focus the field. This was an automation interaction detail, not an app amount-handling failure.

## 9. Whether goals amount handling is trustworthy enough to continue

Yes.

For goal target creation and reopen/edit preservation, the tested dot-decimal and Spanish thousands/decimal inputs preserved the intended numeric value in input, display, and SQLite storage.

## 10. Exact next safe action

Continue to the next currency validation area or cleanup decision. Do not change goal amount logic unless a new failing case appears.
