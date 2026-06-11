# Amount Input Limit Fix

## 1. Executive summary
Fixed the app-wide artificial money-entry digit limit in the shared currency input formatter. Users can now type larger whole-number amounts naturally, including 6, 7, and 8 digits, while retaining the existing Spanish thousands grouping and prior dot/comma decimal behavior.

## 2. Files modified
- `lib/core/utils/currency_input_formatter.dart`
- `.codex/reports/amount_input_limit_fix.md`

## 3. Root cause
Money fields across transactions, debts, goals, and budgets reuse `CurrencyInputFormatter`.

The formatter previously treated existing thousands separators as decimal separators during incremental typing. After the formatter produced values like `12.345` or `1.234.567`, typing another digit created text such as `12.3456` or `1.234.5678`. The formatter then interpreted the dot state as invalid decimal/multi-dot input and returned `oldValue`, which made the field appear to stop accepting more digits.

No `maxLength` or `LengthLimitingTextInputFormatter` was found in the checked money input paths.

## 4. Exact fix applied
Updated only `CurrencyInputFormatter`:

- A single dot with 0-2 trailing digits still stays available for active dot-decimal entry, preserving cases like `12.50`.
- Multiple dots with 0-2 trailing digits still convert the last dot to a comma decimal separator, preserving cases like typing `1250.75` after `1.250`.
- Dots with more trailing digits now fall through to the existing thousands regrouping path instead of returning `oldValue`.
- The parser and screen save logic were not changed.

## 5. Validation results by area
Device: Samsung SM G990E, device id `R5CW51JJ10N`.

Build/install:

- Built debug APK with `C:\flutter\bin\flutter.bat build apk --debug --no-pub`.
- Installed with `adb install -r build\app\outputs\flutter-apk\app-debug.apk`.

Results:

- New movement amount: passed. Typing `12345678` displayed `12.345.678`.
- Debt total amount: passed. Typing `12345678` displayed `12.345.678`.
- Goal target amount: passed. Typing `12345678` displayed `12.345.678`.
- Budget amount: passed. Typing `12345678` displayed `12.345.678`.

These checks validated field-entry capacity only and did not save new records.

## 6. Remaining risk, if any
Low. The shared formatter path was validated in the requested areas. This pass did not rerun full save/storage validation for large amounts, and did not retest every decimal combination because the scope was the digit-entry limit and prior decimal validation had already passed.

## 7. Exact next safe action
Run a narrow save/storage validation for one large amount in each money area if needed; otherwise continue with the next focused runtime smoke pass.
