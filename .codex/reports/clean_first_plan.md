# Clean First Plan

Audit date: 2026-05-11

Scope: planning only. This report does not modify app source, stage files, revert files, rename files, or delete files.

## 1. Executive summary

Release work should stop until the dirty repo is made intentional. The current working tree mixes unrelated categories of work: Codex skill setup, old skill deletions, audit artifacts, broad UI polish, financial input changes, debt/goal rewrites, Firebase/Auth additions, cloud backup exposure, and generated localization changes.

The app can still be finished safely, but not on top of this mixed state. The minimum safe move is to preserve planning artifacts, restore or intentionally resolve skill deletions, isolate the high-risk app work, then restart release fixes from a known baseline.

Decision counts in the companion table:

- KEEP: 20 files
- REVIEW: 11 files
- REVERT: 17 files
- ISOLATE: 20 files

## 2. Why release work must stop right now

- Financial input logic is dirty in multiple places at once: helper, formatter, transaction screen, budgets, debts, goals, savings goals, and transaction service.
- Auth and cloud backup are being exposed through routes, settings, backup screen, main provider wiring, and new services, but account deletion, data deletion, privacy copy, and restore are still incomplete.
- Shared UI components changed globally, so a small visual tweak may affect unrelated release blocker work.
- Several files have staged and unstaged changes at the same time, which makes intent unclear.
- Old tracked skill files are deleted while new replacement skills are untracked, adding non-app noise to every release diff.
- Generated localization files are dirty and should be regenerated or verified as a unit, not hand-kept casually.

## 3. Clean baseline definition

A safe release-fix baseline means:

- App source contains only intentional, reviewed changes.
- No file is both staged and unstaged.
- Old skill deletions are either restored or explicitly accepted outside app release work.
- New audit artifacts and agent setup are preserved separately from app changes.
- Auth/cloud backup exposure is either fully isolated or intentionally selected for release scope.
- Currency/calculation changes are isolated until they can be tested with real amount examples.
- Release fixes begin from a state where `git status --short` is understandable in one screen.

## 4. Grouped action plan in safest order

1. Preserve planning artifacts.
   Keep `.codex/**`, `AGENTS.md`, and the new instruction-only skills if they are intentionally part of the repo workflow.

2. Resolve skill churn before app work.
   Restore the 17 deleted old skill files unless the user explicitly wants the old skill set removed. This is unrelated to the product release and should not be mixed with app fixes.

3. Isolate auth/cloud work.
   Keep the auth/cloud files out of the release-fix baseline unless the first release will ship Google sign-in and cloud backup with account deletion, cloud data deletion, accurate privacy copy, and restore behavior.

4. Isolate financial input work.
   Treat currency helper, currency formatter, transaction service, transaction add screen, budget, debt, goal, and savings changes as one patch. Do not keep only part of it.

5. Review shared UI changes.
   Shared controls like `AppButton`, `GlassCard`, and `GradientButton` can create broad visual regressions. They should not be mixed with release blocker fixes unless deliberately accepted.

6. Review localization and Firebase platform config.
   Keep generated localization files only if they match ARB/manual translation sources. Keep iOS Firebase files only after platform identity is confirmed.

7. Start release fixes only after the baseline is clean.
   The first release-fix work should then focus on premium test behavior, privacy/Data safety, account deletion decision, cloud scope decision, and signing/AAB readiness.

## 5. Files to KEEP

- `.codex/checklists/final_ship_plan.md`
- `.codex/checklists/release_blockers_checklist.md`
- `.codex/reports/project_audit.md`
- `.codex/reports/playstore_readiness_audit.md`
- `.codex/reports/dirty_repo_review.md`
- `AGENTS.md`
- `.agents/skills/arquitectura-flutter-simple/SKILL.md`
- `.agents/skills/auditor-dependencias-flutter/SKILL.md`
- `.agents/skills/auditor-flujos-financieros/SKILL.md`
- `.agents/skills/estabilidad-android-flutter/SKILL.md`
- `.agents/skills/expense-architecture-auditor/SKILL.md`
- `.agents/skills/expense-feature-builder/SKILL.md`
- `.agents/skills/expense-financial-logic/SKILL.md`
- `.agents/skills/expense-orchestrator/SKILL.md`
- `.agents/skills/expense-qa-bug-hunter/SKILL.md`
- `.agents/skills/expense-release-finisher/SKILL.md`
- `.agents/skills/expense-ui-ux/SKILL.md`
- `.agents/skills/proyecto-orquestador-app-gastos/SKILL.md`
- `.agents/skills/seguridad-android-play/SKILL.md`
- `.agents/skills/ux-fintech-simple/SKILL.md`

## 6. Files to REVIEW manually

- `lib/core/i18n/app_translations.dart`
- `lib/core/ui/quick_action_menu.dart`
- `lib/core/ui/widgets/glass_input.dart`
- `lib/features/transactions/widgets/transaction_history_list.dart`
- `lib/firebase_options.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_es.dart`
- `ios/Runner/GoogleService-Info.plist`

## 7. Files to REVERT

These are repo skill deletions, not product app code. Revert them unless the old skill set was intentionally removed:

- `.agents/skills/arquitecto-software-senior/SKILL.md`
- `.agents/skills/auditor-dependencias-android/SKILL.md`
- `.agents/skills/auditor-economico-financiero/SKILL.md`
- `.agents/skills/auditor-matematico-financiero/SKILL.md`
- `.agents/skills/auditor-seguridad-android/SKILL.md`
- `.agents/skills/consultor-cumplimiento-google-play/SKILL.md`
- `.agents/skills/creador-de-habilidades/SKILL.md`
- `.agents/skills/disenador-web-moderno/SKILL.md`
- `.agents/skills/equipo-auditoria-elite-android/SKILL.md`
- `.agents/skills/especialista-seguridad-android/SKILL.md`
- `.agents/skills/especialista-ux-fintech/SKILL.md`
- `.agents/skills/ingeniero-estabilidad-android/SKILL.md`
- `.agents/skills/ingeniero-rendimiento-android/SKILL.md`
- `.agents/skills/optimizador-talla-android/SKILL.md`
- `.agents/skills/qa-testing-destructivo/SKILL.md`
- `.agents/skills/traductor-elite-profesional/SKILL.md`
- `.agents/skills/traductor-tecnico-software/SKILL.md`

## 8. Files to ISOLATE

- `lib/core/flow/premium_flow_service.dart`
- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`
- `lib/core/ui/app_button.dart`
- `lib/core/ui/glass_card.dart`
- `lib/core/ui/widgets/gradient_button.dart`
- `lib/core/utils/currency_helper.dart`
- `lib/core/utils/currency_input_formatter.dart`
- `lib/features/budgets/screens/budget_screen.dart`
- `lib/features/debts/screens/debt_screen.dart`
- `lib/features/goals/screens/goal_screen.dart`
- `lib/features/goals/screens/savings_goals_screen.dart`
- `lib/features/settings/screens/backup_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/features/transactions/screens/add_transaction_screen.dart`
- `lib/main.dart`
- `lib/services/cloud_backup_service.dart`
- `lib/services/transaction_service.dart`
- `lib/features/auth/screens/auth_screen.dart`
- `lib/services/auth_service.dart`

## 9. Dependency warnings

- `lib/core/router/app_router.dart`, `lib/core/router/app_routes.dart`, `lib/features/settings/screens/settings_screen.dart`, `lib/features/settings/screens/backup_screen.dart`, `lib/main.dart`, `lib/features/auth/screens/auth_screen.dart`, `lib/services/auth_service.dart`, and `lib/services/cloud_backup_service.dart` form one auth/cloud dependency chain. Do not keep one part while reverting another.
- `lib/core/utils/currency_helper.dart`, `lib/core/utils/currency_input_formatter.dart`, `lib/features/transactions/screens/add_transaction_screen.dart`, `lib/services/transaction_service.dart`, `lib/features/budgets/screens/budget_screen.dart`, `lib/features/debts/screens/debt_screen.dart`, `lib/features/goals/screens/goal_screen.dart`, and `lib/features/goals/screens/savings_goals_screen.dart` form one financial input chain. Do not keep partial parser/formatter changes without the screens that depend on them.
- `lib/core/ui/app_button.dart`, `lib/core/ui/glass_card.dart`, `lib/core/ui/widgets/gradient_button.dart`, `lib/core/flow/premium_flow_service.dart`, `lib/features/debts/screens/debt_screen.dart`, and `lib/features/goals/screens/savings_goals_screen.dart` form a shared UI chain. Layout changes should be accepted or removed together.
- `lib/core/i18n/app_translations.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, and generated `lib/l10n/app_localizations*.dart` must stay consistent. Do not keep generated files without source translation confirmation.
- `lib/firebase_options.dart` and `ios/Runner/GoogleService-Info.plist` should be reviewed together. They are not Android release blockers, but they are Firebase identity/config changes.

## 10. Exact safe next action

Do not start release fixes. First ask the user to choose one cleanup path:

1. Preserve `.codex/**`, `AGENTS.md`, and new skills.
2. Restore the 17 deleted old skill files unless their deletion was intentional.
3. Move the 20 ISOLATE app files into a separate review checkpoint outside release fixes, or have the user explicitly approve keeping one dependency chain at a time.
4. Re-run `git status --short`.
5. Begin release work only after the remaining dirty state is intentional and dependency-consistent.
