# Old Skills Review

Audit date: 2026-05-11

Scope: read-only review of deleted tracked skill files versus the current `AGENTS.md` and `.agents/skills/**` setup. No application code, `AGENTS.md`, or skill files were modified in this pass.

## 1. Executive summary

There are 17 deleted tracked old skill files under `.agents/skills/**`. There are also 14 current untracked skill files plus a root `AGENTS.md`.

The current setup is enough to continue safely with the expense app because it is focused, instruction-only, and aligned with the repository's simple finance-app goals. Most deleted old skills are broader, overlapping, or less targeted than the current expense-specific setup.

The deletion itself still needs to be made intentional before app-source cleanup begins. Leaving the old skills as deleted is not a product runtime risk, but it keeps the repo dirty and can confuse future cleanup/release diffs.

Decision summary:

- RESTORE: 0
- KEEP DELETED: 12
- REVIEW MANUALLY: 5

## 2. Deleted skill-related items found

Deleted tracked files:

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

No deleted skill folders can be evaluated separately from their `SKILL.md` files because each old skill appears to have been a single-file skill folder.

## 3. Current agent setup status

`AGENTS.md` is present and contains safe local rules:

- Agent/skill setup work should only edit `AGENTS.md` and `.agents/skills/**`.
- Skill creation must not touch application code.
- Changes should be small, safe, reversible, and instruction-only unless scripts are explicitly requested.
- Current architecture and naming conventions should be preserved.

Current `.agents/skills/**` contains 14 instruction-only skills:

- `arquitectura-flutter-simple`
- `auditor-dependencias-flutter`
- `auditor-flujos-financieros`
- `estabilidad-android-flutter`
- `expense-architecture-auditor`
- `expense-feature-builder`
- `expense-financial-logic`
- `expense-orchestrator`
- `expense-qa-bug-hunter`
- `expense-release-finisher`
- `expense-ui-ux`
- `proyecto-orquestador-app-gastos`
- `seguridad-android-play`
- `ux-fintech-simple`

This setup is sufficient for the next cleanup and release-preparation work. It covers orchestration, architecture, dependencies, financial logic, UI/UX, feature building, QA, stability, release finishing, Android/Play security, and safe app-specific planning.

## 4. Restore / keep deleted / review manually decision for each deleted item

| Deleted item | Decision | Reason |
| --- | --- | --- |
| `.agents/skills/arquitecto-software-senior/SKILL.md` | KEEP DELETED | Superseded by `arquitectura-flutter-simple` and `expense-architecture-auditor`, which are more specific to this Flutter expense app. |
| `.agents/skills/auditor-dependencias-android/SKILL.md` | KEEP DELETED | Superseded by `auditor-dependencias-flutter`, which covers Flutter, Android plugins, Firebase, Google Sign-In, purchases, notifications, and local auth. |
| `.agents/skills/auditor-economico-financiero/SKILL.md` | KEEP DELETED | Superseded by `auditor-flujos-financieros` and `expense-financial-logic`, which are more practical for the app's calculations and flows. |
| `.agents/skills/auditor-matematico-financiero/SKILL.md` | KEEP DELETED | Superseded by `expense-financial-logic` and `auditor-flujos-financieros`. |
| `.agents/skills/auditor-seguridad-android/SKILL.md` | KEEP DELETED | Superseded by `seguridad-android-play` plus `expense-release-finisher`. |
| `.agents/skills/consultor-cumplimiento-google-play/SKILL.md` | KEEP DELETED | Superseded by `seguridad-android-play` and release-readiness skills. |
| `.agents/skills/creador-de-habilidades/SKILL.md` | REVIEW MANUALLY | A system `skill-creator` skill already exists, but the old local Spanish creator may be useful if the repo wants local Spanish-only skill authoring guidance. |
| `.agents/skills/disenador-web-moderno/SKILL.md` | KEEP DELETED | Not relevant to the current Flutter expense app release cleanup. |
| `.agents/skills/equipo-auditoria-elite-android/SKILL.md` | KEEP DELETED | Too broad and duplicated by the current focused skill set. The new setup is safer for small modular work. |
| `.agents/skills/especialista-seguridad-android/SKILL.md` | KEEP DELETED | Superseded by `seguridad-android-play`; keeping both would duplicate security guidance. |
| `.agents/skills/especialista-ux-fintech/SKILL.md` | KEEP DELETED | Superseded by `ux-fintech-simple` and `expense-ui-ux`, which better match the simple app tone. |
| `.agents/skills/ingeniero-estabilidad-android/SKILL.md` | KEEP DELETED | Superseded by `estabilidad-android-flutter` and `expense-qa-bug-hunter`. |
| `.agents/skills/ingeniero-rendimiento-android/SKILL.md` | REVIEW MANUALLY | Current skills mention performance basics, but there is no dedicated performance specialist. Consider restoring only if performance work becomes a separate phase. |
| `.agents/skills/optimizador-talla-android/SKILL.md` | REVIEW MANUALLY | Current release skills can flag size risk, but there is no dedicated APK/AAB size optimizer. Consider restoring only if bundle size becomes a release issue. |
| `.agents/skills/qa-testing-destructivo/SKILL.md` | KEEP DELETED | Superseded enough by `expense-qa-bug-hunter` for this simple app. Full destructive testing is useful later but not needed before cleanup. |
| `.agents/skills/traductor-elite-profesional/SKILL.md` | REVIEW MANUALLY | Localization matters, but this is a general translation skill. Restore only if Spanish/English copy cleanup will be a dedicated workflow. |
| `.agents/skills/traductor-tecnico-software/SKILL.md` | REVIEW MANUALLY | Could help with technical copy/docs, but is not needed for immediate release cleanup. |

## 5. Risks if left as-is

Current Codex workflow risk: low to medium.

The current skills are enough for app cleanup and release planning. The risk is mostly that deleted tracked skill files keep the repo dirty, making it harder to see app-source changes clearly.

Repo safety risk: medium.

The current `AGENTS.md` is safe and the active skills are instruction-only. The issue is unresolved intent: old tracked skills are deleted while new untracked skills exist. That should be resolved before app-source cleanup so future diffs do not mix agent setup with product changes.

Release preparation risk: low.

Deleting old skills does not affect the Flutter app, Android release config, Firebase, calculations, tests, or Play Store declarations. It only affects local Codex guidance.

Capability risk: low.

The current setup covers the important release domains. The only possible gaps are specialized Android performance, AAB/APK size optimization, and dedicated translation workflows.

## 6. Whether current agent setup is enough

Yes. The current `AGENTS.md` and `.agents/skills/**` setup is sufficient to continue safely with cleanup planning and release preparation.

The current setup is actually better aligned with this app than the deleted broad skill set because it is:

- expense-app specific
- Flutter/Android aware
- release-safety oriented
- instruction-only
- focused on small, reversible work
- clear about not touching app code during skill setup

The only condition: the deleted tracked skills must be intentionally resolved before app-source cleanup begins, either by keeping the deletion as an agent-setup cleanup or by restoring the few optional skills the user still wants.

## 7. Exact safe next action

Do not restore or delete anything automatically.

Ask the user to approve one of these two safe paths:

1. Keep the current focused skill setup and accept the old skill deletions, with manual review only for `creador-de-habilidades`, `ingeniero-rendimiento-android`, `optimizador-talla-android`, `traductor-elite-profesional`, and `traductor-tecnico-software`.
2. Restore the old skill set first to make the repo cleaner, then decide separately whether to remove broad/duplicate skills in a dedicated agent-setup cleanup.

Recommended path: keep the current focused setup, review the 5 optional deleted skills manually, and do not let agent-skill cleanup block app-source cleanup longer than necessary.
