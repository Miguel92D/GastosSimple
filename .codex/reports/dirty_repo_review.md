# Dirty Repository Review

Audit date: 2026-05-11

Scope: read-only review of dirty/uncommitted files before release fix work. No app source files were modified in this pass.

Dirty paths found before this report: 64.

## 1. Summary of dirty changes

The repository is not clean enough for release fixes yet. There are 64 dirty paths:

- 28 modified tracked app files under `lib/`.
- 3 untracked app/native files: `lib/features/auth/screens/auth_screen.dart`, `lib/services/auth_service.dart`, `ios/Runner/GoogleService-Info.plist`.
- 9 paths with staged changes, several of which also have unstaged changes.
- 17 deleted tracked skill files under `.agents/skills/`.
- 14 untracked replacement/new skill folders.
- 4 untracked audit artifacts under `.codex/`.
- 1 untracked root `AGENTS.md`.

The app-source dirty changes are not random polish only. They touch release-sensitive areas: premium gating, auth routing, Firebase options, cloud backup, settings, currency parsing/formatting, transaction input, debts, budgets, goals, and generated localization files.

The biggest process risk is that some files are partially staged and partially unstaged. Release fixes should not begin until the existing changes are either intentionally kept, intentionally reverted by the user, or isolated into a checkpoint.

## 2. File-by-file review

### Safe and relevant for release

| File | Status | Review | Recommendation |
| --- | --- | --- | --- |
| `.codex/checklists/final_ship_plan.md` | untracked | Audit artifact from prior release readiness pass. Does not affect app runtime. | Keep |
| `.codex/checklists/release_blockers_checklist.md` | untracked | Audit artifact from prior release readiness pass. Does not affect app runtime. | Keep |
| `.codex/reports/playstore_readiness_audit.md` | untracked | Audit artifact from prior release readiness pass. Does not affect app runtime. | Keep |
| `.codex/reports/project_audit.md` | untracked | Audit artifact from prior release readiness pass. Does not affect app runtime. | Keep |
| `AGENTS.md` | untracked | Local Codex guidance. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/expense-*` | untracked | Instruction-only skills for this app. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/arquitectura-flutter-simple/SKILL.md` | untracked | Local Spanish architecture skill. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/auditor-dependencias-flutter/SKILL.md` | untracked | Local dependency audit skill. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/auditor-flujos-financieros/SKILL.md` | untracked | Local financial-flow audit skill. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/estabilidad-android-flutter/SKILL.md` | untracked | Local stability audit skill. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/proyecto-orquestador-app-gastos/SKILL.md` | untracked | Local project orchestration skill. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/seguridad-android-play/SKILL.md` | untracked | Local Android/Play security skill. Does not affect app runtime. | Keep if intentionally created |
| `.agents/skills/ux-fintech-simple/SKILL.md` | untracked | Local UX audit skill. Does not affect app runtime. | Keep if intentionally created |

### Risky / unclear

| File | Status | Review | Recommendation |
| --- | --- | --- | --- |
| `lib/core/flow/premium_flow_service.dart` | modified | Replaces a simple `ElevatedButton` with `AppButton`. This depends on the modified `AppButton` behavior and could affect premium upsell layout. | Review |
| `lib/core/ui/app_button.dart` | modified | Converts the shared button to a `GlassCard`/`InkWell` implementation with larger padding and glow. This affects every `AppButton` caller and could create layout regressions. | Review carefully |
| `lib/core/ui/glass_card.dart` | modified | Changes glow/shadow behavior globally. Mostly visual, but shared UI changes can cause overflow or performance cost. | Review |
| `lib/core/ui/quick_action_menu.dart` | modified | Spacing-only change. Low risk but should be visually checked. | Keep after visual QA |
| `lib/core/ui/widgets/glass_input.dart` | staged modified | Small staged UI/input change, but staged content was not fully inspected in this pass. | Review |
| `lib/core/ui/widgets/gradient_button.dart` | modified | Adds wrapper padding around a shared button. Could shift layouts across the app. | Review |
| `lib/core/utils/currency_helper.dart` | staged and unstaged modified | Changes parsing and adds display formatting. Directly affects financial inputs and totals. Current parsing strips dots before commas no longer works the same way; values using dot decimals may be interpreted differently. | Review with tests before keep |
| `lib/core/utils/currency_input_formatter.dart` | staged added and unstaged modified | New formatter is central to amount entry. It has staged and unstaged differences, so the current working copy may not match the intended patch. | Review with tests before keep |
| `lib/features/budgets/screens/budget_screen.dart` | staged and unstaged modified | Uses the new currency formatting. This is relevant but coupled to risky formatter changes. | Review with calculation tests |
| `lib/features/debts/screens/debt_screen.dart` | staged and unstaged modified | Large UI and behavior rewrite around debt forms, date formatting, payment defaults, priority display, and currency formatting. High regression surface. | Review deeply |
| `lib/features/goals/screens/goal_screen.dart` | staged and unstaged modified | Uses new currency formatting in goal input. Relevant but coupled to formatter behavior. | Review |
| `lib/features/goals/screens/savings_goals_screen.dart` | staged and unstaged modified | Large UI/modal rewrite and formatter usage. High visual and financial-input regression surface. | Review deeply |
| `lib/features/transactions/screens/add_transaction_screen.dart` | staged and unstaged modified | Changes edit amount formatting and fixes `context.watch` inside save error path. Relevant, but financial input parsing must be validated. | Review with transaction tests |
| `lib/features/transactions/widgets/transaction_history_list.dart` | modified | Spacing-only change in list bottom area. Low risk. | Keep after visual QA |
| `lib/services/transaction_service.dart` | staged modified | Financial service changed, but only staged diff summary was inspected. This is release-sensitive. | Review before any release work |
| `lib/core/i18n/app_translations.dart` | modified | Adds `priority_label` and `google_auth_error`. Relevant, but only one auth error key appears added to manual translations. | Review |
| `lib/l10n/app_en.arb` | modified | Adds `priority_label`. | Keep if generated files are regenerated consistently |
| `lib/l10n/app_es.arb` | modified | Adds `priority_label`. | Keep if generated files are regenerated consistently |
| `lib/l10n/app_localizations.dart` | modified | Generated localization update. Should not be hand-edited unless generated by Flutter tooling. | Review generation source |
| `lib/l10n/app_localizations_en.dart` | modified | Generated localization update. | Review generation source |
| `lib/l10n/app_localizations_es.dart` | modified | Generated localization update. | Review generation source |
| `lib/firebase_options.dart` | modified | Adds iOS Firebase options. Not an Android release blocker, but it changes Firebase platform behavior and introduces another app identity to verify. | Review |
| `ios/Runner/GoogleService-Info.plist` | untracked | iOS Firebase config. Not relevant to Google Play, but should be verified before keeping. | Review |

### Likely experimental or unfinished

| File | Status | Review | Recommendation |
| --- | --- | --- | --- |
| `lib/core/router/app_router.dart` | modified | Adds `/auth` route to untracked auth screen. This exposes an incomplete account flow. | Review or hold |
| `lib/core/router/app_routes.dart` | modified | Adds auth route constant. Safe only if auth flow ships. | Review or hold |
| `lib/features/settings/screens/settings_screen.dart` | modified | Adds "Cuenta Google" entry and wires AuthService. This exposes account/cloud behavior that currently lacks deletion and complete privacy handling. | Hold before release |
| `lib/features/settings/screens/backup_screen.dart` | modified | Adds Google sign-in and cloud backup action. This exposes incomplete cloud flow; restore and deletion remain blockers. | Hold before release |
| `lib/main.dart` | modified | Registers `AuthService` provider. Safe only if auth flow is intentionally shipping. | Hold before release |
| `lib/services/cloud_backup_service.dart` | modified | Adds user metadata, active status, app version, and rethrows full backup errors. Helpful, but still no restore/delete. | Hold until cloud plan is complete |
| `lib/features/auth/screens/auth_screen.dart` | untracked | New auth UI for Google sign-in/sign-out. Missing account deletion/data deletion and full localization. | Hold before release |
| `lib/services/auth_service.dart` | untracked | New Firebase Auth + Google Sign-In wrapper. Missing delete account/delete provider data behavior. | Hold before release |

### Likely should be reverted before release work

| File/group | Status | Review | Recommendation |
| --- | --- | --- | --- |
| `.agents/skills/arquitecto-software-senior/SKILL.md` through `.agents/skills/traductor-tecnico-software/SKILL.md` | 17 deleted tracked files | Large deletion of existing local skills. Not app runtime code, but it makes the repo setup noisy and unrelated to release work. | Revert unless intentionally replacing the old skill set |
| Mixed staged/unstaged state in `lib/core/utils/currency_helper.dart`, `lib/core/utils/currency_input_formatter.dart`, budgets, debts, goals, savings goals, add transaction, and transaction service | staged plus unstaged | This is the most dangerous workflow state. It is hard to know what was intended and what is accidental. | Stop and clean first |

## 3. Keep / review / revert recommendation

Keep:
- Prior audit artifacts under `.codex/`.
- Root `AGENTS.md` and new instruction-only skills only if the skill setup was intentional.
- Low-risk spacing/polish changes only after a visual smoke check.

Review:
- All currency input/formatting changes.
- All debts/goals/budgets transaction input changes.
- All generated localization files.
- Firebase iOS config and `firebase_options.dart`.
- Shared UI component changes.

Revert or hold before release work:
- Deleted old `.agents/skills/**` files unless the deletion was intentional.
- Auth/cloud backup exposure until privacy, Data safety, account deletion, cloud restore, and cloud data deletion are designed.
- Any staged/unstaged partial patches until the intended state is clarified.

## 4. Release risk assessment

Overall dirty-state release risk: high.

How dirty changes affect release stability:

- Financial calculations: high risk. Currency parsing/formatting and amount prefill changed across transactions, budgets, debts, and goals. A small parser mistake can silently corrupt entered amounts.
- Premium behavior: medium risk. `premium_flow_service.dart` depends on the modified shared `AppButton`; this is mostly UI, but premium release blockers already exist elsewhere and should not be mixed with broad UI changes.
- Cloud restore: high risk. New auth/cloud backup entry points make cloud behavior more visible, while restore and deletion are still incomplete.
- Privacy/data deletion flows: high risk. Google account sign-in is being exposed in Settings and Backup, but no account deletion/data deletion flow is present.
- Android release configuration: low direct risk from current dirty files. No Android Gradle or manifest file is dirty, but untracked iOS Firebase config and modified Firebase options show release identity/config work is in progress.
- Testability: high risk. Large UI and financial-input changes are not accompanied by visible test updates.
- Process stability: high risk. Partially staged files mean the repo is in a state where future fixes could accidentally combine unrelated work.

## 5. Safe next action

Stop and clean first.

Do not start release fixes on top of this working tree. First decide what to do with the current dirty work:

1. Preserve the audit artifacts.
2. Decide whether the new skill setup is intentional.
3. Decide whether the old deleted skill files should be restored.
4. Review the staged/unstaged financial-input patch as one unit.
5. Either finish and test the auth/cloud backup flow fully, or remove/hide it before release work.
6. Only after the tree is intentionally organized should release fixes begin.

Recommended next specialist skill: `expense-architecture-auditor` for scope separation, then `expense-financial-logic` for the currency/input patch.
