# Currency Chain Release Strategy

Audit date: 2026-05-11

Scope: decision-only review. No app source files were modified.

## 1. Executive summary

Recommended first-release strategy: **A. Keep the current currency/calculation chain and validate/fix it for release.**

Do not ship the current chain as-is. Keep it as the active working direction because it is trying to solve a real usability problem: consistent money input across transactions, budgets, debts, and goals. However, it must go through a focused validation/fix pass before release.

Reverting the whole chain would reduce dirty-file noise, but it would not solve the existing transaction type inconsistency already identified in the project audit. A mixed approach is riskier because the parser/formatter changes are now spread across shared helpers and multiple screens.

## 2. What the currency/calculation chain currently does

Currency parsing/formatting:

- `lib/core/utils/currency_helper.dart` contains `parseAmount()`.
- Dirty changes add `formatAmountForInput()`.
- Current `parseAmount()` keeps digits, comma, and minus, then converts comma to dot.
- This supports Spanish-style values like `1.234,56` after stripping dots elsewhere, but can misread dot-decimal values like `12.50` as `1250` because dots are treated as thousands separators or removed before parsing.

Numeric input formatting:

- `lib/core/utils/currency_input_formatter.dart` is a new formatter.
- It formats thousands with `.` and decimals with `,`.
- It is used by transaction, budget, debt, goal, and savings goal forms.
- The file is both staged and unstaged, so the intended final formatter behavior is not cleanly established.

Transaction type handling:

- Most of the app uses `ingreso` and `gasto`.
- `Transaction.fromMap()` still defaults missing type to `expense`.
- `DatabaseHelper` totals and repository methods query `ingreso` and `gasto`.
- `TransactionService` calculates `ingreso` and `gasto`.
- `monthly_analysis_screen` checks `income` and `expense`, which conflicts with the dominant app convention.

Totals and rollups:

- `DatabaseHelper.getTotalIncome()` sums rows where `type = 'ingreso'`.
- `DatabaseHelper.getTotalExpenses()` and category aggregation use `type = 'gasto'`.
- Dashboard calculations use `ingreso` and `gasto`.
- Budget repository filters expenses by `gasto`.
- Any record saved as `income` or `expense` can be missed by major totals.

Dependency impact:

- `CurrencyHelper.parseAmount()` affects all dirty screens using money input.
- `CurrencyInputFormatter` affects transaction, budget, debt, goal, and savings goal input.
- Debt and savings changes include large UI/behavior edits beyond parser adoption.
- Several files are both staged and unstaged, increasing process risk.

## 3. Risks of keeping it for first release

Option A risk: medium to high if kept without validation, low to medium after a focused fix pass.

- Current parser can misread dot-decimal input.
- Formatter behavior is not proven across cursor movement, pasted values, negatives, empty strings, symbols, and thousands separators.
- The chain affects several money entry points at once.
- Debt and savings screens include UI/date/payment behavior changes mixed with input parsing.
- Existing type inconsistency can still break monthly analysis and any records using `income`/`expense`.
- Tests are not yet in place to prevent regressions.

Option A is acceptable only if the next pass is deliberately narrow: centralize parsing expectations, fix type normalization, and add representative parser/calculation checks before any release work.

## 4. Risks of reverting it

Option B risk: medium.

- Reverting would remove formatter-related dirty complexity.
- It would likely restore simpler input behavior in affected screens.
- It would also drop useful work toward consistent localized money entry.
- It would not fix the already-known type-value bug (`expense`/`income` versus `gasto`/`ingreso`).
- Older parsing behavior still appears locale-fragile because it assumes dot thousands and comma decimals.
- Reverting without tests may only move the risk back to a less visible baseline.

Option B is safer only if the immediate goal is to remove all financial-input churn and defer locale-friendly input entirely. It is not the safest path to a trustworthy first release because the calculation/type issues still need correction.

## 5. Risks of mixed approach

Option C risk: high.

- Keeping `CurrencyHelper` while reverting formatter screens could leave unused or incompatible methods.
- Keeping formatter screens while reverting helper behavior could break parsing.
- Keeping transaction changes but reverting debt/goal changes creates inconsistent money entry across the app.
- Debt and savings changes depend on shared UI edits as well as currency helpers, making a selective split more error-prone.
- Mixed cleanup would require more decisions and more manual testing than either A or B.

Option D risk: medium to high.

- Hiding budgets/debts/goals temporarily would reduce input surface, but it damages the product and does not fix core transaction parsing or type consistency.
- Hiding financial screens is only justified if a screen is broken beyond quick repair.

## 6. Recommended strategy for first release

Choose **A. Keep the current currency/calculation chain and validate/fix it for release.**

Apply it as a narrow financial correctness pass, not as broad UI polish:

1. Define one app-wide transaction type convention: `ingreso` and `gasto`.
2. Normalize any inbound legacy values `income` and `expense` at model/service boundaries.
3. Define parser behavior for representative inputs:
   - `12`
   - `12,5`
   - `12,50`
   - `1.234`
   - `1.234,56`
   - `$ 1.234,56`
   - invalid and empty values
4. Keep formatter behavior only if it matches parser behavior.
5. Keep debt/goal/budget input changes only after they pass the same parser examples.
6. Add focused tests or a documented manual verification matrix.

## 7. Exact files that would likely need to change later if that strategy is applied

Core parser/type files:

- `lib/core/utils/currency_helper.dart`
- `lib/core/utils/currency_input_formatter.dart`
- `lib/features/transactions/models/transaction.dart`
- `lib/services/transaction_service.dart`
- `lib/database/database_helper.dart`

Affected input screens:

- `lib/features/transactions/screens/add_transaction_screen.dart`
- `lib/features/budgets/screens/budget_screen.dart`
- `lib/features/debts/screens/debt_screen.dart`
- `lib/features/goals/screens/goal_screen.dart`
- `lib/features/goals/screens/savings_goals_screen.dart`

Affected rollup/reporting screens:

- `lib/features/analysis/screens/monthly_analysis_screen.dart`
- `lib/features/dashboard/controllers/dashboard_controller.dart`
- `lib/features/budgets/repositories/budget_repository.dart`
- `lib/features/transactions/repositories/transaction_repository.dart`

Likely tests/checks:

- `test/` focused tests for parser and type normalization, if test setup allows it.
- A manual smoke checklist if automated tests are blocked by Firebase/app initialization.

## 8. Why this is the safest path

- It addresses the real release blocker: users must be able to trust entered amounts and totals.
- It avoids a brittle partial revert across many dependent files.
- It avoids hiding useful app areas like budgets, debts, and goals unless a specific screen proves broken.
- It keeps the direction of consistent money input while requiring proof before release.
- It directly handles the known `income`/`expense` versus `ingreso`/`gasto` inconsistency.
- It is more transparent than pretending the last committed baseline was financially correct.

## 9. Exact safe next action

Run a focused currency/calculation fix pass next:

1. Fix or define `CurrencyHelper.parseAmount()` behavior first.
2. Align `CurrencyInputFormatter` with that parser.
3. Normalize transaction type values at the model/reporting boundaries.
4. Keep code changes limited to financial correctness.
5. Add parser/type verification before moving to premium, privacy, signing, or Play release work.
