# Currency Validation Pass

## 1. Executive summary

This pass re-validated the recently changed currency/calculation chain without making any application source changes.

The static code review found the intended release-safe direction intact:
- `Transaction` now has canonical transaction types: `ingreso` and `gasto`.
- Legacy `income` and `expense` values are normalized before calculations and database writes.
- Database aggregate queries include both canonical and legacy type values where needed.
- Money parsing and formatting now use explicit Spanish-style behavior.
- Main rollups now use normalized helpers instead of raw string comparisons.

However, the chain is not fully release-validated yet because both targeted Dart validation commands timed out:
- `dart format --output=none --set-exit-if-changed ...`
- `dart analyze ...`

No source-code edits were made in this validation pass.

## 2. Files validated

Files from the currency/calculation fix pass:

- `lib/core/utils/currency_helper.dart`
- `lib/core/utils/currency_input_formatter.dart`
- `lib/features/transactions/models/transaction.dart`
- `lib/services/transaction_service.dart`
- `lib/database/database_helper.dart`
- `lib/features/analysis/screens/monthly_analysis_screen.dart`
- `lib/features/analysis/screens/prediction_screen.dart`
- `lib/features/dashboard/controllers/dashboard_controller.dart`
- `lib/features/dashboard/widgets/dashboard_widget.dart`
- `lib/features/budgets/repositories/budget_repository.dart`
- `lib/features/transactions/widgets/transaction_tile.dart`
- `lib/services/suggestion_service.dart`

Direct dependency observations:

- `lib/core/controllers/action_controller.dart`
- `lib/core/ui/app_fab.dart`

These two files still pass `income` and `expense` as route arguments for quick-add actions. They are not part of the stored transaction model, and this remains acceptable only because the add-transaction flow normalizes those route arguments before saving.

## 3. Commands run

Formatting check on touched files only:

```powershell
dart format --output=none --set-exit-if-changed lib\core\utils\currency_helper.dart lib\core\utils\currency_input_formatter.dart lib\features\transactions\models\transaction.dart lib\services\transaction_service.dart lib\database\database_helper.dart lib\features\analysis\screens\monthly_analysis_screen.dart lib\features\analysis\screens\prediction_screen.dart lib\features\dashboard\controllers\dashboard_controller.dart lib\features\dashboard\widgets\dashboard_widget.dart lib\features\budgets\repositories\budget_repository.dart lib\features\transactions\widgets\transaction_tile.dart lib\services\suggestion_service.dart
```

Analyzer check on touched files only:

```powershell
dart analyze lib\core\utils\currency_helper.dart lib\core\utils\currency_input_formatter.dart lib\features\transactions\models\transaction.dart lib\services\transaction_service.dart lib\database\database_helper.dart lib\features\analysis\screens\monthly_analysis_screen.dart lib\features\analysis\screens\prediction_screen.dart lib\features\dashboard\controllers\dashboard_controller.dart lib\features\dashboard\widgets\dashboard_widget.dart lib\features\budgets\repositories\budget_repository.dart lib\features\transactions\widgets\transaction_tile.dart lib\services\suggestion_service.dart
```

Whitespace check on touched files only:

```powershell
git diff --check -- lib\core\utils\currency_helper.dart lib\core\utils\currency_input_formatter.dart lib\features\transactions\models\transaction.dart lib\services\transaction_service.dart lib\database\database_helper.dart lib\features\analysis\screens\monthly_analysis_screen.dart lib\features\analysis\screens\prediction_screen.dart lib\features\dashboard\controllers\dashboard_controller.dart lib\features\dashboard\widgets\dashboard_widget.dart lib\features\budgets\repositories\budget_repository.dart lib\features\transactions\widgets\transaction_tile.dart lib\services\suggestion_service.dart
```

Targeted legacy type scan:

```powershell
rg 'type\s*(==|:)\s*["''](income|expense)["'']' lib
```

## 4. Command results

Formatting check:

- Result: timed out after 120 seconds.
- No formatting pass/fail result was produced.

Analyzer check:

- Result: timed out after 120 seconds.
- No analyzer pass/fail result was produced.

Whitespace check:

- Result: passed with exit code `0`.
- Only Git line-ending warnings were reported for CRLF conversion; no whitespace errors were reported.

Targeted legacy type scan:

- Result: completed successfully.
- Remaining matches:
  - `lib/core/controllers/action_controller.dart`
  - `lib/core/ui/app_fab.dart`
- Assessment: these are quick-add route arguments, not stored model values. They remain a dependency on add-transaction normalization and should be manually smoke-tested.

## 5. Static validation findings

Parser behavior:

- Empty input returns `null`.
- Non-numeric input such as `abc` returns `null`.
- Currency symbols and spaces are stripped before parsing.
- Both comma and dot separators are supported.
- When both comma and dot exist, the last separator is treated as the decimal separator.
- A single separator followed by exactly three digits is treated as a thousands separator.
- More than two decimal digits are rejected.
- Negative values can parse, but normal entry flows still need positive-value validation at the screen level.

Formatter behavior:

- Output is Spanish-style: dot thousands and comma decimals.
- Trailing `.0` display noise is removed for input formatting.
- The input formatter accepts dot decimal input when no comma exists and the decimal part has one or two digits.
- The formatter rejects additional decimal precision by preserving the previous value.

Canonical transaction types:

- Canonical stored values are `ingreso` and `gasto`.
- `Transaction.normalizeType` maps `income` to `ingreso`.
- `Transaction.normalizeType` maps `expense` to `gasto`.
- Unknown, empty, or missing type values default to `gasto`, which is conservative for balance safety.
- `Transaction.toMap`, `fromMap`, and `copyWith` normalize values consistently.

Totals and rollups:

- Service-level income and expense calculations now use `isIncome` and `isExpense`.
- Dashboard calculations now use normalized transaction helpers.
- Monthly analysis and prediction calculations now use normalized transaction helpers.
- Budget spending now uses normalized expense checks.
- Transaction tile display now uses normalized type helpers.
- Database aggregate queries include canonical and legacy type values.

Legacy compatibility:

- Existing rows with `income` or `expense` should still be included in totals.
- New transaction writes should use canonical Spanish values.
- Route arguments still use legacy English values in quick-add entry points, but those are expected to be normalized before persistence.

## 6. Checklist coverage review

Covered by static validation:

- Parser behavior for common separators, decimals, invalid text, empty input, and currency symbols.
- Formatter behavior for dot/comma input and two-decimal precision.
- Canonical transaction type normalization.
- Legacy type compatibility.
- Totals and rollup code paths in the touched files.

Not covered because runtime/manual testing was not executed in this pass:

- Actual income entry in the app.
- Actual expense entry in the app.
- Editing an existing transaction.
- Totals after mixed income and expense records.
- Debt totals in the running app.
- Goals totals in the running app.
- Monthly analysis totals in the running app.
- Keyboard/input behavior on Android.
- Persistence behavior after app restart.

## 7. Remaining high-risk issues, if any

High-risk release validation gaps remain:

- Targeted `dart format` timed out, so formatting compliance is not confirmed.
- Targeted `dart analyze` timed out, so static analyzer correctness is not confirmed.
- The manual checklist has not been run in a real app session.
- Quick-add route arguments still use `income` and `expense`; this is acceptable only if add-transaction normalization is verified manually.
- Negative parsed amounts depend on screen-level validation to prevent invalid saved money values.

No new high-risk source inconsistency was found during static review.

## 8. Whether the currency/calculation chain is safe enough to continue

No.

The code direction appears coherent, but the chain is not safe enough to continue into release fixes until at least one of the following is completed:

- targeted Dart validation finishes successfully, or
- the timeout cause is documented and a narrower analyzer/format strategy is used, and
- the manual currency validation checklist is run against the app.

## 9. Exact next safe action

Retry validation with a narrower command strategy:

1. Run `dart format --output=none --set-exit-if-changed` on one touched file at a time.
2. Run `dart analyze` on the smallest high-risk subset first:
   - `lib/core/utils/currency_helper.dart`
   - `lib/core/utils/currency_input_formatter.dart`
   - `lib/features/transactions/models/transaction.dart`
   - `lib/database/database_helper.dart`
   - `lib/services/transaction_service.dart`
3. Run the manual checklist in `.codex/checklists/currency_validation_checklist.md`.
4. Only after that, continue to the next release cleanup area.
