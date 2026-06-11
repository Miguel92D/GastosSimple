1. Executive summary

Fixed the runtime dot-decimal formatter bug in the amount input field. `12.50` no longer becomes `1.250`, and `1250.75` no longer becomes `125.075` or an invalid multi-dot value.

Focused device validation confirmed the requested dot-decimal, comma-decimal, and Spanish thousands cases now save with the expected stored values.

2. Files modified

- `lib/core/utils/currency_input_formatter.dart`
- `.codex/reports/currency_dot_decimal_fix.md`

3. Root cause

`CurrencyInputFormatter` stripped `.` characters too early while the user was still typing. During incremental input, `12.` became `12`; then the next digits were treated as whole-number digits and grouped as thousands, producing `1.250`.

There was a second related runtime path for `1250.75`: after typing `1250`, the formatter correctly displayed `1.250`; typing `.75` after that produced `1.250.75`, which was invalid and stayed on the add screen.

4. Exact fix applied

Updated only `CurrencyInputFormatter` dot handling:

- A single dot with zero, one, or two digits after it is preserved as active dot-decimal input.
- If the value already has a thousands dot and the user adds another dot with up to two digits after it, the last dot is treated as the decimal separator and converted to comma, so `1250.75` becomes `1.250,75` in the field.
- Existing comma-decimal and Spanish thousands flows still use the existing formatter path.
- No parser, screen, service, auth/cloud, or Android release config files were touched.

5. Focused validation re-check results

Device:

- SM G990E / R5CW51JJ10N

Command:

```powershell
C:\flutter\bin\flutter.bat run -d R5CW51JJ10N --debug --no-pub
```

Final validation baseline:

```text
max id: 18
```

Final validation rows:

```text
(19, 12.5, 'Salario', 'ingreso', 0, '2026-05-11T23:08:47.767183')
(20, 1250.75, 'Comida', 'gasto', 0, '2026-05-11T23:09:05.116016')
(21, 12.5, 'Salario', 'ingreso', 0, '2026-05-11T23:09:22.521920')
(22, 1250.0, 'Comida', 'gasto', 0, '2026-05-11T23:09:40.638314')
(23, 1250.75, 'Salario', 'ingreso', 0, '2026-05-11T23:09:58.433598')
```

Case results:

- `12.50`: passed. Typed field stayed `12.50`; stored as `12.5`.
- `1250.75`: passed. Typed field displayed `1.250,75`; stored as `1250.75`.
- `12,50`: passed. Typed field stayed `12,50`; stored as `12.5`.
- `1.250`: passed. Typed field stayed `1.250`; stored as `1250.0`.
- `1.250,75`: passed. Typed field stayed `1.250,75`; stored as `1250.75`.

6. Remaining risk, if any

This pass validated only the requested quick-entry amount cases. It did not retest edit flows, debts, goals, budgets, monthly analysis, or prediction screens.

The device database still contains earlier intentionally-created bad validation rows from the pre-fix runtime pass. They are useful test evidence, but a later manual validation pass should account for them or use a clean data set.

7. Exact next safe action

Run the broader currency checklist on a clean test data set or after removing the deliberately-created bad validation rows, starting with edit-flow amount preservation and then debts/goals/budget amount inputs.
