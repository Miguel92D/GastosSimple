# Chain Cleanup Pass 1

Audit date: 2026-05-11

Scope: auth/cloud and currency/calculation dirty chains only.

## 1. Executive summary

This pass isolated the two highest-risk dirty chains by documenting their exact file boundaries, dependency relationships, and remaining risks. No app source file was changed because every file in these chains was previously classified as `ISOLATE` or `REVIEW`, not `REVERT`, and no safe mechanical isolation method was explicitly approved.

The safest minimal cleanup decision is to keep both chains out of release-fix work until the user chooses one concrete action for each chain:

- keep and finish the chain as intentional work
- revert the chain to the last committed baseline
- split the chain into a separate checkpoint outside release fixes

## 2. Files actually changed

- `.codex/reports/chain_cleanup_pass_1.md`
- `.codex/reports/auth_cloud_chain_status.md`
- `.codex/reports/currency_calculation_chain_status.md`

No app source files were modified in this pass.

## 3. Files intentionally left untouched

Auth/cloud chain:

- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/main.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`
- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`

Currency/calculation chain:

- `lib/core/utils/currency_helper.dart`
- `lib/core/utils/currency_input_formatter.dart`
- `lib/features/transactions/screens/add_transaction_screen.dart`
- `lib/services/transaction_service.dart`
- `lib/features/budgets/screens/budget_screen.dart`
- `lib/features/debts/screens/debt_screen.dart`
- `lib/features/goals/screens/goal_screen.dart`
- `lib/features/goals/screens/savings_goals_screen.dart`

## 4. Reverted files

None.

No file in the auth/cloud or currency/calculation chains was marked `REVERT` in the prior decision table. Reverting these files now would be a destructive cleanup choice, so it was not done without an explicit follow-up instruction.

## 5. Isolated files

Isolated for later auth/cloud decision:

- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/main.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`

Left as `REVIEW` inside auth/cloud boundary:

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`

Isolated for later currency/calculation decision:

- `lib/core/utils/currency_helper.dart`
- `lib/core/utils/currency_input_formatter.dart`
- `lib/features/transactions/screens/add_transaction_screen.dart`
- `lib/services/transaction_service.dart`
- `lib/features/budgets/screens/budget_screen.dart`
- `lib/features/debts/screens/debt_screen.dart`
- `lib/features/goals/screens/goal_screen.dart`
- `lib/features/goals/screens/savings_goals_screen.dart`

## 6. Dependency warnings

- Auth route files depend on the untracked auth screen and auth service. Do not keep route changes if the auth files are removed or ignored.
- Settings and backup screens expose Google sign-in/cloud backup. They should not ship unless account deletion, cloud data deletion, privacy copy, and restore behavior are resolved.
- `main.dart` provider registration depends on `lib/services/auth_service.dart`.
- `cloud_backup_service.dart` depends on the Firebase Auth/Firestore model and remains incomplete without restore/delete decisions.
- Currency formatter/helper changes affect transaction, budget, debt, goal, and savings forms together. Do not keep only one screen without validating parser behavior across the chain.
- The currency/calculation chain includes staged and unstaged changes. That mixed state must be resolved before coding release fixes.

## 7. Risks remaining

- Auth/cloud remains unsafe for release because it exposes account/cloud behavior without deletion, accurate privacy handling, and full restore.
- Currency/calculation remains unsafe because parser and formatter changes can silently alter financial values.
- Debts and savings goals carry large UI/behavior changes inside the currency chain.
- Partially staged files still exist in the currency/calculation chain.
- No tests were run and no app behavior was validated in this pass.

## 8. Exact clean baseline status after this pass

The repo is cleaner conceptually, not mechanically.

- The two highest-risk chains are now explicitly bounded.
- No unsafe chain was partially reverted.
- No unrelated files were touched.
- Release fixes should still not begin until the user chooses the concrete isolation action for these chains.

Baseline status: not clean enough for release fixes yet.

## 9. Exact next safe action

Choose one concrete action for each isolated chain:

1. Auth/cloud: either revert/hide the unfinished auth-cloud exposure for the first release, or keep the whole chain and complete account deletion, cloud data deletion, privacy, and restore later.
2. Currency/calculations: either revert the whole chain to the previous committed input behavior, or keep the whole chain and run a dedicated financial parser/test pass before any release work.

Recommended next action: revert or checkpoint the auth/cloud chain first because it creates Play policy and privacy risk even before calculation correctness is tested.
