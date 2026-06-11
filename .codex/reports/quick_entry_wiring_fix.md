1. Executive summary

Fixed the quick-entry expense wiring bug with a single route/type normalization change. Quick-entry income still opens with income defaults, and quick-entry expense now opens with expense defaults/categories.

2. Files modified

- `lib/core/flow/transaction_flow_service.dart`
- `.codex/reports/quick_entry_wiring_fix.md`

3. Root cause

Quick-entry route arguments were forwarding legacy transaction type names such as `income` and `expense` through the navigation flow. Recent currency work made `ingreso` and `gasto` the canonical app values, while keeping legacy names compatible. The quick-entry handoff still depended on later inference instead of normalizing the route state before opening the add movement screen.

4. Exact fix applied

In `TransactionFlowService.startQuickEntry()`, route type values are now normalized before navigation:

- `income` and `ingreso` become `Transaction.typeIncome` / `ingreso`.
- `expense`, `gasto`, missing unknowns, and other non-income values become `Transaction.typeExpense` / `gasto`.
- Both `type` and `initialTipo` route argument keys are normalized when present, preserving compatibility with existing callers that use either key.
- No auth/cloud, Android release config, business logic outside the quick-entry transaction route handoff, or broad refactors were touched.

5. Smoke re-check results

Command used:

```powershell
C:\flutter\bin\flutter.bat run -d R5CW51JJ10N --debug --no-pub
```

Wrapper context:

```powershell
$env:GIT_CONFIG_COUNT='1'
$env:GIT_CONFIG_KEY_0='safe.directory'
$env:GIT_CONFIG_VALUE_0='C:/flutter'
```

Device:

- SM G990E / R5CW51JJ10N

Results:

- Quick-entry income: passed. Tapping the income card opened `Nuevo movimiento` with income categories including `SALARIO`, `INVERSIÓN`, `VENTA`, and `REGALO`.
- Quick-entry expense: passed after clean app restart to the quick-entry screen. Tapping the expense card opened `Nuevo movimiento` with expense categories including `COMIDA`, `OTROS`, `TRANSPORTE`, and `SALUD`.

Captured evidence:

- `.codex/reports/quick_entry_wiring_fix_flutter_run_stdout.log`
- `.codex/reports/quick_entry_wiring_fix_flutter_run_stderr.log`
- `C:\tmp\gastos_income_after_fix.xml`
- `C:\tmp\gastos_expense_clean_start_after.xml`

6. Remaining risk, if any

The focused smoke test verified only the two quick-entry buttons requested. It did not validate saving transactions, dashboard totals after save, currency parsing, or wider navigation.

7. Exact next safe action

Run the next targeted validation pass for saving one income and one expense from quick-entry, then verify dashboard income/expense totals before continuing the currency validation checklist.
