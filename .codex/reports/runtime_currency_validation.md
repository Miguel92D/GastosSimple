1. Executive summary

Runtime currency validation found a real money input bug. Comma decimal, Spanish thousands, Spanish thousands-plus-decimal, whole-number, zero rejection, and empty rejection behaved correctly in the tested quick-entry flows. Dot decimal input did not.

First failing case: `12.50` was transformed in the amount field to `1.250`, saved as `1250.0`, displayed as `$1,250`, and increased expense totals by `1250` instead of `12.5`.

No application source file was modified in this pass.

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

Baseline before this pass:

```text
max id: 8
income:  1008501.78
expense: 51921.0
balance: 956580.78
```

Positive save cases:

| Case | Flow | Expected value | Result |
| --- | --- | ---: | --- |
| `12,50` | quick-entry income | `12.5` | Passed |
| `12.50` | quick-entry expense | `12.5` | Failed |
| `1.250` | quick-entry income | `1250.0` | Passed |
| `1.250,75` | quick-entry expense | `1250.75` | Passed |
| `1250.75` | quick-entry income | `1250.75` | Failed |
| `1250` | quick-entry expense | `1250.0` | Passed |

Rejection cases:

| Case | Flow | Expected behavior | Result |
| --- | --- | --- | --- |
| `0` | quick-entry income | Reject, stay on add screen, no row saved | Passed |
| Empty input | quick-entry expense | Reject, stay on add screen, no row saved | Passed |

Invalid text such as `abc` was not tested through the device UI because the amount field is numeric and the positive/rejection cases above already exposed the runtime blocker.

4. Input interpretation results

Passed:

- `12,50` remained `12,50` in the amount field and saved as `12.5`.
- `1.250` remained `1.250` in the amount field and saved as `1250.0`.
- `1.250,75` remained `1.250,75` in the amount field and saved as `1250.75`.
- `1250` saved as `1250.0`.
- `0` and empty input stayed on `Nuevo movimiento` and did not save.

Failed:

- `12.50` became `1.250` in the amount field before save.
- `1250.75` became `125.075` in the amount field before save.

5. Stored value results

Rows saved during this pass:

```text
(9, 12.5, 'Salario', 'ingreso', 0, '2026-05-11T22:56:02.956354')
(10, 1250.0, 'Comida', 'gasto', 0, '2026-05-11T22:56:20.355359')
(11, 1250.0, 'Salario', 'ingreso', 0, '2026-05-11T22:56:37.817195')
(12, 1250.75, 'Comida', 'gasto', 0, '2026-05-11T22:56:55.340493')
(13, 125075.0, 'Salario', 'ingreso', 0, '2026-05-11T22:57:12.759680')
(14, 1250.0, 'Comida', 'gasto', 0, '2026-05-11T22:57:30.199352')
```

Stored value pass/fail:

- `12,50` stored correctly as `12.5`.
- `12.50` stored incorrectly as `1250.0`.
- `1.250` stored correctly as `1250.0`.
- `1.250,75` stored correctly as `1250.75`.
- `1250.75` stored incorrectly as `125075.0`.
- `1250` stored correctly as `1250.0`.
- `0` and empty input did not add rows. Max id stayed `14` after rejection checks.

6. Display/totals results

Final database totals after the positive cases:

```text
income:  1134839.28
expense: 55671.75
balance: 1079167.53
```

Final dashboard showed the same values:

```text
balance: $1,079,167.53
income:  $1,134,839.28
expense: $55,671.75
```

The dashboard and stored totals are internally consistent, but they reflect the wrong dot-decimal stored values. If dot decimal inputs had parsed correctly, the added income and added expense would have balanced each other at `2513.25` each. Instead, the dot-decimal failures inflated income by `123824.25` and expense by `1237.5` beyond the expected values.

Visible transaction display also reflected the stored values:

- `12,50` displayed as `+$12.50`.
- `12.50` displayed as `-$1,250`.
- `1.250` displayed as `+$1,250`.
- `1.250,75` displayed as `-$1,250.75`.
- `1250.75` displayed as `+$125,075`.
- `1250` displayed as `-$1,250`.

7. First failing case, if any

`12.50` in quick-entry expense.

Exact failure:

- Typed input: `12.50`
- Amount field before save: `1.250`
- Stored value: `1250.0`
- Stored type/category: `gasto` / `Comida`
- Visible transaction: `-$1,250`
- Dashboard expense total increased by `1250` instead of `12.5`.

8. Whether runtime currency behavior is trustworthy enough to continue

No.

The app correctly handles comma decimal and Spanish-style formatted values, but dot-decimal input is a runtime money bug. Since `12.50` and `1250.75` are representative user inputs and save incorrect values, runtime currency behavior should be fixed before broader validation continues.

9. Exact next safe action

Run a source-fix pass focused only on `CurrencyInputFormatter` dot-decimal handling so dot decimals with one or two decimal digits remain decimal values during typing. Then rerun this focused runtime currency validation for `12.50`, `1250.75`, `12,50`, `1.250`, and `1.250,75`.
