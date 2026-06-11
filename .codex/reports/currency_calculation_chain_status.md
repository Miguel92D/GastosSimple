# Currency / Calculation Chain Status

Audit date: 2026-05-11

## 1. Files in chain

| File | Current dirty status | Prior decision | Decision applied in this pass |
| --- | --- | --- | --- |
| `lib/core/utils/currency_helper.dart` | staged and unstaged modified | ISOLATE | Isolated in report; left untouched |
| `lib/core/utils/currency_input_formatter.dart` | staged added and unstaged modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/transactions/screens/add_transaction_screen.dart` | staged and unstaged modified | ISOLATE | Isolated in report; left untouched |
| `lib/services/transaction_service.dart` | staged modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/budgets/screens/budget_screen.dart` | staged and unstaged modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/debts/screens/debt_screen.dart` | staged and unstaged modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/goals/screens/goal_screen.dart` | staged and unstaged modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/goals/screens/savings_goals_screen.dart` | staged and unstaged modified | ISOLATE | Isolated in report; left untouched |

## 2. Decision applied per file

- Every file in this chain was previously marked `ISOLATE`.
- No file was previously marked `REVERT`.
- Because this chain contains financial input behavior and mixed staged/unstaged changes, it was left untouched and documented as one unit.

## 3. What was changed

Only this report and the pass summary report were created. No currency/calculation source file was changed.

## 4. What remains risky

- `CurrencyHelper.parseAmount` and `CurrencyInputFormatter` changes can alter how user-entered money is parsed.
- The formatter/helper changes affect transaction, budget, debt, goal, and savings flows.
- Several files have both staged and unstaged changes, so the intended final patch is unclear.
- Debt and savings screens include large behavior/UI changes beyond simple amount parsing.
- No calculation tests were run in this pass.

## 5. Whether this chain is now safe enough to continue

No.

This chain is now clearly isolated as a review unit, but it is not safe for release fixes until one of these happens:

- revert the whole chain to the previous committed financial input behavior, or
- keep the whole chain and run a focused financial parser/calculation validation pass with representative examples.
