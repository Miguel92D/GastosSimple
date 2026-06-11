# Dirty Files Decision Table

Audit date: 2026-05-11

Scope: dirty files present before this cleanup-planning pass. This table excludes `clean_first_plan.md` and this file itself.

| File path | Risk level | Area | Decision | Short reason | Dependency notes |
| --- | --- | --- | --- | --- | --- |
| `.codex/checklists/final_ship_plan.md` | low | other | KEEP | Planning artifact; no runtime effect. | Keep with `.codex` reports. |
| `.codex/checklists/release_blockers_checklist.md` | low | other | KEEP | Planning artifact; no runtime effect. | Keep with `.codex` reports. |
| `.codex/reports/project_audit.md` | low | other | KEEP | Audit artifact; no runtime effect. | Keep with `.codex` reports. |
| `.codex/reports/playstore_readiness_audit.md` | low | other | KEEP | Audit artifact; no runtime effect. | Keep with `.codex` reports. |
| `.codex/reports/dirty_repo_review.md` | low | other | KEEP | Source report for this cleanup plan. | Keep with `.codex` reports. |
| `AGENTS.md` | low | other | KEEP | Local agent guidance; no app runtime effect. | Keep if intentionally created. |
| `.agents/skills/arquitectura-flutter-simple/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/auditor-dependencias-flutter/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/auditor-flujos-financieros/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/estabilidad-android-flutter/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-architecture-auditor/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-feature-builder/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-financial-logic/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-orchestrator/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-qa-bug-hunter/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-release-finisher/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/expense-ui-ux/SKILL.md` | low | other | KEEP | Requested project skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/proyecto-orquestador-app-gastos/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/seguridad-android-play/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/ux-fintech-simple/SKILL.md` | low | other | KEEP | Instruction-only skill; no app runtime effect. | Keep with new skill set. |
| `.agents/skills/arquitecto-software-senior/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/auditor-dependencias-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/auditor-economico-financiero/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/auditor-matematico-financiero/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/auditor-seguridad-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/consultor-cumplimiento-google-play/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/creador-de-habilidades/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/disenador-web-moderno/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/equipo-auditoria-elite-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/especialista-seguridad-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/especialista-ux-fintech/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/ingeniero-estabilidad-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/ingeniero-rendimiento-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/optimizador-talla-android/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/qa-testing-destructivo/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/traductor-elite-profesional/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `.agents/skills/traductor-tecnico-software/SKILL.md` | low | other | REVERT | Deleted old skill unrelated to release work. | Restore unless deletion was intentional. |
| `lib/core/flow/premium_flow_service.dart` | medium | premium | ISOLATE | Premium upsell UI changed and depends on shared button changes. | Depends on `AppButton`. |
| `lib/core/i18n/app_translations.dart` | medium | other | REVIEW | Translation keys added; must match generated localization and actual UI usage. | Review with ARB/generated files. |
| `lib/core/router/app_router.dart` | high | auth | ISOLATE | Exposes new auth route backed by untracked auth screen. | Part of auth/cloud chain. |
| `lib/core/router/app_routes.dart` | high | auth | ISOLATE | Adds auth route constant; useful only if auth ships. | Part of auth/cloud chain. |
| `lib/core/ui/app_button.dart` | high | ui | ISOLATE | Shared button implementation changed globally. | Affects premium, debts, goals, and any AppButton caller. |
| `lib/core/ui/glass_card.dart` | medium | ui | ISOLATE | Shared card shadow/glow behavior changed. | Needed by modified `AppButton`. |
| `lib/core/ui/quick_action_menu.dart` | low | ui | REVIEW | Spacing-only change; low risk but visual. | No critical dependency. |
| `lib/core/ui/widgets/glass_input.dart` | medium | ui | REVIEW | Staged input UI change; inspect before keeping. | May affect forms broadly. |
| `lib/core/ui/widgets/gradient_button.dart` | medium | ui | ISOLATE | Shared button spacing/layout changed. | Shared UI chain. |
| `lib/core/utils/currency_helper.dart` | high | calculations | ISOLATE | Parser/formatter changes affect all money input. | Core financial input chain. |
| `lib/core/utils/currency_input_formatter.dart` | high | calculations | ISOLATE | New/modified formatter has staged and unstaged changes. | Core financial input chain. |
| `lib/features/budgets/screens/budget_screen.dart` | high | calculations | ISOLATE | Budget amount formatting depends on new currency helper. | Depends on currency chain. |
| `lib/features/debts/screens/debt_screen.dart` | high | calculations | ISOLATE | Large debt UI/date/payment/amount changes. | Depends on currency and shared UI chains. |
| `lib/features/goals/screens/goal_screen.dart` | high | calculations | ISOLATE | Goal amount formatting depends on new helper. | Depends on currency chain. |
| `lib/features/goals/screens/savings_goals_screen.dart` | high | calculations | ISOLATE | Large savings UI/modal/amount changes. | Depends on currency and shared UI chains. |
| `lib/features/settings/screens/backup_screen.dart` | high | cloud | ISOLATE | Exposes Google sign-in/cloud backup while restore/delete remain incomplete. | Auth/cloud chain. |
| `lib/features/settings/screens/settings_screen.dart` | high | auth | ISOLATE | Adds Google account entry and exposes incomplete account flow. | Auth/cloud chain. |
| `lib/features/transactions/screens/add_transaction_screen.dart` | high | calculations | ISOLATE | Transaction edit amount formatting and validation behavior changed. | Depends on currency chain. |
| `lib/features/transactions/widgets/transaction_history_list.dart` | low | ui | REVIEW | Spacing-only change; verify visual result. | No critical dependency. |
| `lib/firebase_options.dart` | medium | cloud | REVIEW | Adds iOS Firebase config; platform identity must be verified. | Review with iOS plist. |
| `lib/l10n/app_en.arb` | medium | other | REVIEW | ARB source changed; must match generated files. | Localization chain. |
| `lib/l10n/app_es.arb` | medium | other | REVIEW | ARB source changed; must match generated files. | Localization chain. |
| `lib/l10n/app_localizations.dart` | medium | other | REVIEW | Generated file changed; verify generation source. | Localization chain. |
| `lib/l10n/app_localizations_en.dart` | medium | other | REVIEW | Generated file changed; verify generation source. | Localization chain. |
| `lib/l10n/app_localizations_es.dart` | medium | other | REVIEW | Generated file changed; verify generation source. | Localization chain. |
| `lib/main.dart` | high | auth | ISOLATE | Registers new AuthService provider; useful only if auth ships. | Auth/cloud chain. |
| `lib/services/cloud_backup_service.dart` | high | cloud | ISOLATE | Cloud metadata/error behavior changed while restore/delete remain incomplete. | Auth/cloud chain. |
| `lib/services/transaction_service.dart` | high | calculations | ISOLATE | Financial service is staged and release-sensitive. | Core financial input/calculation chain. |
| `ios/Runner/GoogleService-Info.plist` | medium | cloud | REVIEW | New iOS Firebase config, not needed for Android release but should be verified. | Review with `firebase_options.dart`. |
| `lib/features/auth/screens/auth_screen.dart` | high | auth | ISOLATE | New account UI lacks deletion/data deletion and full localization. | Auth/cloud chain. |
| `lib/services/auth_service.dart` | high | auth | ISOLATE | New auth wrapper lacks account deletion/data deletion. | Auth/cloud chain. |

## Counts

- KEEP: 20
- REVIEW: 11
- REVERT: 17
- ISOLATE: 20
