# Large Amount Save Validation

## 1. Executive summary

Focused validation was run on the physical debug device after the shared amount-input limit fix. Large amounts could be entered, saved, persisted across app force-stop/reopen, and displayed correctly in the main money flows tested: new movement, debt, goal, and budget.

No application source files were modified in this pass.

## 2. Target device used

- Device: `R5CW51JJ10N`
- App package: `com.migueld.gastossimple`
- Build context: installed debug app on the same working Android device context

## 3. New movement validation result

Pass.

- Case tested: `100000`
- Input interpretation: amount field displayed `100.000`
- Save result: save completed through the visible `GUARDAR` button
- Stored/display verification after force-stop/reopen: dashboard showed balance `$1,055,667.78`, income `$1,107,267.78`, and recent movement `Salario / 12 May, 2026 / +$100,000`
- Summary coherence: income and balance increased by `$100,000` from the previous observed dashboard state

## 4. Debt validation result

Pass.

- Case tested: `250000`
- Input interpretation: amount field displayed `250.000`
- Save result: debt `DebtLarge250000` saved
- Stored/display verification after force-stop/reopen `/debts`: `DEUDA TOTAL: $250,000`, debt card `DebtLarge250000`, amount `$250,000`
- Summary coherence: debt total matched the saved debt amount

## 5. Goal validation result

Pass.

- Case tested: `250000`
- Input interpretation: amount field displayed `250.000`
- Save result: goal `GoalLarge250000` saved
- Stored/display verification after force-stop/reopen `/goals` and scrolling: `GoalLarge250000`, `$0 / $250,000`, monthly target `$20,833.33 / mes`
- Summary coherence: active goal count increased and the displayed monthly target was coherent for the saved target

## 6. Budget validation result

Pass.

- Case tested: `1250000`
- Input interpretation: budget dialog displayed `1.250.000`
- Save result: `Otros` budget saved
- Stored/display verification after force-stop/reopen `/budgets`: `Otros`, `$0 / $1,250,000`
- Direct persistence verification: `shared_prefs/FlutterSharedPreferences.xml` contained `flutter.budget_Otros` with stored double value `1250000.0`
- Summary coherence: budget display matched the saved limit

## 7. Cases tested per area

- New movement: `100000`
- Debt: `250000`
- Goal target: `250000`
- Budget: `1250000`

The app also previously validated entry capacity for larger shared money inputs in `.codex/reports/amount_input_limit_fix.md`; this pass focused on save, persistence, and display.

## 8. First failing case, if any

None.

Automation note: an initial goal attempt was inconclusive because the target amount field was not focused before typing; the successful follow-up showed the amount field populated before save and verified the saved result after reopen.

## 9. Whether large amount handling is trustworthy enough to continue

Yes.

The tested flows accepted large values, saved them, displayed them correctly, and read them back after app process restart. SQLite-backed flows were verified through app persistence after force-stop/reopen; direct SQLite querying was not available in this shell because no device/local `sqlite3` tool was present.

## 10. Exact next safe action

Continue with the next narrow release-readiness runtime validation; keep any future amount checks focused on decimal large values only if a specific decimal regression is suspected.
