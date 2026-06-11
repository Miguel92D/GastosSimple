# Final Ship Plan

Audit date: 2026-05-11

## Phase 1: Lock release scope

Goal: keep the app simple and shippable.

- Decide if first release is local-first only or local-first with optional cloud backup.
- Keep dashboard, quick add, add/edit/delete transactions, history, settings, PIN/biometrics, and local backup.
- Defer unfinished recurring/goal linkage/cloud restore if they cannot be completed safely.
- Remove visible demo/test behavior.

Recommended skill: `expense-orchestrator`.

## Phase 2: Remove Play blockers

Goal: make the app acceptable for internal testing.

- Remove premium test unlock fallback.
- Fix privacy policy copy.
- Add account deletion/cloud data deletion if auth remains enabled.
- Complete or hide cloud restore.
- Align Data safety with actual Firebase and app behavior.

Recommended skill: `expense-release-finisher`.

## Phase 3: Fix financial correctness

Goal: make totals trustworthy.

- Normalize transaction type values across model, database, forms, and aggregate methods.
- Verify income, expenses, balance, category totals, debts, and monthly summaries.
- Add focused tests around calculation behavior.

Recommended skill: `expense-financial-logic`.

## Phase 4: Stabilize app flows

Goal: prove the app works without crashes.

- Run `flutter analyze`.
- Repair stale widget/smoke tests.
- Test first launch, add income, add expense, edit/delete, PIN, biometric, backup, restore or hidden restore, offline auth state, and settings.
- Verify loading, empty, and error states.

Recommended skill: `expense-qa-bug-hunter`.

## Phase 5: Android release setup

Goal: produce a valid internal test artifact.

- Configure release signing with an upload key.
- Remove release debug signing fallback.
- Build `flutter build appbundle --release`.
- Inspect release merged manifest permissions.
- Test the `.aab` through Play internal testing.

Recommended skill: `expense-release-finisher`.

## Phase 6: Final UX polish

Goal: make the app feel calm, clear, and trustworthy.

- Simplify settings around account, backup, security, and premium.
- Clean mixed language strings.
- Add helpful empty states.
- Check accessibility basics and low-end Android performance.
- Confirm app name, icon, store listing copy, screenshots, privacy URL, support email, and content rating.

Recommended skill: `expense-ui-ux`.

## Release readiness score

Current estimate: 38/100.

Target before Play internal test: 75/100.

Target before production rollout: 90/100.

## Safe next action

Start with `expense-release-finisher` to remove the premium test unlock, resolve privacy/account deletion decisions, and prepare signing/AAB work. This removes the highest Play rejection risk before deeper polish.
