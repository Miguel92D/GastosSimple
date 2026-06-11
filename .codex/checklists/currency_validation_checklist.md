# Currency Validation Checklist

Audit date: 2026-05-11

## Common currency input examples

- [ ] `12` saves/parses as `12`.
- [ ] `12,5` saves/parses as `12.5`.
- [ ] `12,50` saves/parses as `12.5`.
- [ ] `12.50` saves/parses as `12.5`.
- [ ] `1.234` saves/parses as `1234`.
- [ ] `1.234,56` saves/parses as `1234.56`.
- [ ] `$ 1.234,56` saves/parses as `1234.56`.
- [ ] Empty input is rejected where amount is required.
- [ ] `0` is rejected where amount must be positive.
- [ ] Invalid text such as `abc` is rejected.
- [ ] Invalid separators such as `1,2,3` are rejected.

## Income entry

- [ ] Add income from quick entry.
- [ ] Add income from normal add transaction flow.
- [ ] Confirm saved transaction type is treated as `ingreso`.
- [ ] Confirm dashboard income total increases by the entered amount.

## Expense entry

- [ ] Add expense from quick entry.
- [ ] Add expense from normal add transaction flow.
- [ ] Confirm saved transaction type is treated as `gasto`.
- [ ] Confirm dashboard expense total increases by the entered amount.

## Editing an existing transaction

- [ ] Open an existing income transaction.
- [ ] Confirm amount is prefilled in readable input format.
- [ ] Save without changing amount and confirm total is unchanged.
- [ ] Change amount and confirm totals update correctly.
- [ ] Repeat for an expense transaction.

## Mixed totals

- [ ] Add income `1000`.
- [ ] Add expense `250,50`.
- [ ] Confirm income total is `1000`.
- [ ] Confirm expense total is `250.5`.
- [ ] Confirm balance is `749.5`.
- [ ] Confirm transaction list displays income as positive and expense as negative.

## Debts totals

- [ ] Create debt with total `1.234,56`.
- [ ] Create debt with minimum payment `123,45`.
- [ ] Record payment `12.50`.
- [ ] Confirm debt remaining/progress uses parsed amounts correctly.

## Goals totals

- [ ] Create goal target `1.234,56`.
- [ ] Add money `12,50`.
- [ ] Confirm goal current amount and progress update correctly.
- [ ] Edit goal target and confirm amount remains correct.

## Monthly analysis totals

- [ ] Add at least one income and one expense in the current month.
- [ ] Open monthly analysis.
- [ ] Confirm income uses `ingreso` records.
- [ ] Confirm expense uses `gasto` records.
- [ ] Confirm daily average uses expense total only.
- [ ] Confirm previous-month comparison uses expense records only.

## Prediction totals

- [ ] Open prediction screen with mixed income/expense records.
- [ ] Confirm current income uses income records only.
- [ ] Confirm current expense uses expense records only.
- [ ] Confirm predicted balance subtracts predicted expenses from income.

## Budgets

- [ ] Set budget using `1.234,56`.
- [ ] Confirm budget limit displays the expected value.
- [ ] Add expense in that category.
- [ ] Confirm spent amount uses expense records only.
- [ ] Confirm income in that category does not count as spent.

## Edge cases

- [ ] Currency symbol prefix does not break parsing.
- [ ] Leading/trailing spaces do not break parsing.
- [ ] Negative values are not accepted in user flows that require positive amounts.
- [ ] Existing legacy `income` records are counted as `ingreso`.
- [ ] Existing legacy `expense` records are counted as `gasto`.
