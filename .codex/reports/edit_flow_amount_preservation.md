1. Executive summary

Validated edit-flow amount preservation on the same physical Android device. Five representative amounts were created, reopened in edit mode, checked in the amount field, and re-saved without changes.

No application source file was modified in this pass.

Result: edit-flow amount handling passed for the tested quick-entry income and expense records.

2. Target device used

- Device: SM G990E
- Device id: R5CW51JJ10N
- Package: `com.migueld.gastossimple`
- Debug command:

```powershell
C:\flutter\bin\flutter.bat run -d R5CW51JJ10N --debug --no-pub
```

Wrapper context:

```powershell
$env:GIT_CONFIG_COUNT='1'
$env:GIT_CONFIG_KEY_0='safe.directory'
$env:GIT_CONFIG_VALUE_0='C:/flutter'
```

3. Cases tested

Baseline before the full edit-flow cases:

```text
max id: 24
count: 24
income:  1137403.28
expense: 59422.5
balance: 1077980.78
```

Cases:

| Case | Flow | Expected stored value | Edit field value |
| --- | --- | ---: | --- |
| `12,50` | income | `12.5` | `12,5` |
| `12.50` | expense | `12.5` | `12,5` |
| `1.250` | income | `1250.0` | `1.250` |
| `1.250,75` | expense | `1250.75` | `1.250,75` |
| `1250.75` | income | `1250.75` | `1.250,75` |

4. Edit-field preservation results

Passed.

Observed edit-field values:

```text
edit_12_comma_50_income: 12,5
edit_12_dot_50_expense: 12,5
edit_1_dot_250_income: 1.250
edit_1_dot_250_comma_75_expense: 1.250,75
edit_1250_dot_75_income: 1.250,75
```

These values preserve the saved numeric meaning using the app's Spanish-style edit format.

5. Re-save results

Passed.

Each edited record was saved unchanged and returned to dashboard. The database had exactly five new rows after the full validation pass, which means edit re-save updated the same records and did not create duplicates.

Rows after create plus edit re-save:

```text
(25, 12.5, 'Salario', 'ingreso', 0, '2026-05-11T23:16:14.646989')
(26, 12.5, 'Comida', 'gasto', 0, '2026-05-11T23:16:44.187269')
(27, 1250.0, 'Salario', 'ingreso', 0, '2026-05-11T23:17:13.607191')
(28, 1250.75, 'Comida', 'gasto', 0, '2026-05-11T23:17:43.279986')
(29, 1250.75, 'Salario', 'ingreso', 0, '2026-05-11T23:18:13.467679')
```

Final count:

```text
max id: 29
count: 29
```

6. Totals/display verification

Passed.

Final database totals:

```text
income:  1139916.53
expense: 60685.75
balance: 1079230.78
```

Final dashboard showed matching totals:

```text
balance: $1,079,230.78
income:  $1,139,916.53
expense: $60,685.75
```

Recent list displayed expected values:

```text
Salario +$1,250.75
Comida  -$1,250.75
Salario +$1,250
Comida  -$12.50
Salario +$12.50
```

7. First failing case, if any

None found in this focused edit-flow validation.

8. Whether edit-flow amount handling is trustworthy enough to continue

Yes.

For the tested representative quick-entry income and expense records, edit mode preserved the amount meaning, re-save did not corrupt stored values, and dashboard totals remained consistent with the database.

9. Exact next safe action

Continue the currency checklist with non-transaction amount fields: debts, goals, and budget inputs, using the same representative decimal and thousands cases.
