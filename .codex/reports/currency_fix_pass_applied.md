# Currency Fix Pass Applied

Audit date: 2026-05-11

Scope: focused currency/calculation chain fix. Auth/cloud and Android release config were not touched.

## 1. Executive summary

Applied a focused financial correctness pass:

- Defined canonical transaction types as `ingreso` and `gasto`.
- Normalized legacy `income` and `expense` values at the model boundary.
- Updated database aggregate queries to include both canonical and legacy type values.
- Made parser behavior explicit for comma and dot decimal/thousands inputs.
- Aligned the input formatter with Spanish-style display while accepting dot decimal input safely.
- Updated rollup/reporting paths to use normalized transaction type helpers.

No new features were added.

## 2. Files modified

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
- `.codex/reports/currency_fix_pass_applied.md`
- `.codex/checklists/currency_validation_checklist.md`

## 3. Canonical transaction type decision

Canonical app values:

- Income: `ingreso`
- Expense: `gasto`

Compatibility behavior:

- `income` normalizes to `ingreso`.
- `expense` normalizes to `gasto`.
- Missing or unknown types default to `gasto`.

Where applied:

- `Transaction.normalizeType()`
- `Transaction.toMap()`
- `Transaction.fromMap()`
- `Transaction.copyWith()`
- `Transaction.isIncome`
- `Transaction.isExpense`

## 4. Parser behavior decision

`CurrencyHelper.parseAmount()` now:

- Trims input.
- Removes currency symbols and text.
- Accepts comma or dot decimals.
- Accepts Spanish-style thousands and decimals: `1.234,56`.
- Accepts common dot decimal input: `12.50`.
- Treats a single separator followed by exactly 3 digits as thousands: `1.234` -> `1234`.
- Rejects invalid repeated separators that are not valid thousands groups.
- Returns `null` for empty or invalid inputs.

Representative expected parsing:

- `12` -> `12`
- `12,5` -> `12.5`
- `12,50` -> `12.5`
- `12.50` -> `12.5`
- `1.234` -> `1234`
- `1.234,56` -> `1234.56`
- `$ 1.234,56` -> `1234.56`
- `abc` -> `null`
- empty input -> `null`

## 5. Formatter behavior decision

`CurrencyInputFormatter` remains Spanish-style for display:

- Thousands separator: `.`
- Decimal separator: `,`
- Maximum two decimal digits.

It now treats dot decimal input as comma decimal when the dot is followed by one or two digits. This prevents `12.50` from being formatted or parsed as `1250`.

## 6. Calculation fixes applied

- Dashboard totals use `Transaction.isIncome` and `Transaction.isExpense`.
- Monthly analysis uses normalized type helpers instead of `income`/`expense`.
- Prediction screen uses normalized type helpers.
- Suggestions use normalized expense checks.
- Budget spent calculation uses normalized expense checks.
- Transaction tile display uses `isIncome`.
- Database totals include legacy rows saved as `income`/`expense`.
- Database type filters include canonical and legacy values.

## 7. Dependent screens/services adjusted

Adjusted:

- Dashboard controller and widget filtering
- Monthly analysis
- Prediction screen
- Budget repository
- Transaction tile
- Suggestion service
- Transaction service
- Database helper aggregate/type queries

Left untouched intentionally:

- Existing transaction, budget, debt, goal, and savings goal form UI changes were not redesigned.
- Quick-entry route arguments still pass `income`/`expense` in some places, because the add transaction screen already normalizes route args to `ingreso`/`gasto`.

## 8. Representative cases to test

Parser/input cases:

- `12`
- `12,5`
- `12,50`
- `12.50`
- `1.234`
- `1.234,56`
- `$ 1.234,56`
- empty input
- `0`
- invalid text
- invalid repeated separators such as `1,2,3`

App flow cases:

- Add income and verify dashboard income total.
- Add expense and verify dashboard expense total.
- Edit an existing transaction and verify amount is preserved.
- Add one `ingreso` and one `gasto` and verify balance.
- Verify budget spent uses only expense records.
- Verify debts parse total, minimum payment, and payment amount.
- Verify goals parse target and added amount.
- Verify monthly analysis income/expense totals.
- Verify prediction income/expense totals.

## 9. Remaining risks

- `dart format` timed out after 120 seconds, so formatting was not proven by tool output.
- `dart analyze` timed out after 120 seconds, so analyzer validation was not completed.
- The broader repo still has unrelated dirty UI and release-readiness changes.
- Existing debt and savings goal screens include larger dirty UI changes from before this pass.
- No automated parser test was added because the current test setup is already flagged as stale and may be blocked by app/Firebase initialization.

## 10. Exact next safe action

Run a manual currency smoke pass using `.codex/checklists/currency_validation_checklist.md`, then retry analyzer/formatting after the dirty repo is simplified. If manual checks pass, proceed to the next release blocker: premium test unlock behavior.
