# Manual Deleted Skills Final Review

Audit date: 2026-05-11

Scope: read-only final decision for the 5 deleted skill files previously marked `REVIEW MANUALLY`. No application code, `AGENTS.md`, or `.agents/skills/**` files were modified.

## 1. Executive summary

The 5 manually reviewed deleted skills are optional. None are required before app-source cleanup or release preparation can continue.

The current focused skill setup already covers the release-critical work: architecture, dependencies, financial logic, UX, QA, stability, Play/security readiness, and release finishing. The deleted optional skills add narrower convenience workflows for skill authoring, Android performance, AAB/APK size, and translation, but they are not needed to clean the repo or continue release planning.

Final decision summary:

- KEEP DELETED: 1
- RESTORE LATER: 2
- OPTIONAL / NO EFFECT: 2

## 2. The 5 manually reviewed deleted items

- `.agents/skills/creador-de-habilidades/SKILL.md`
- `.agents/skills/ingeniero-rendimiento-android/SKILL.md`
- `.agents/skills/optimizador-talla-android/SKILL.md`
- `.agents/skills/traductor-elite-profesional/SKILL.md`
- `.agents/skills/traductor-tecnico-software/SKILL.md`

## 3. Item-by-item final decision

| Deleted item | What it likely did | Current coverage | Safe to keep deleted? | Restore later? | Final decision |
| --- | --- | --- | --- | --- | --- |
| `.agents/skills/creador-de-habilidades/SKILL.md` | Provided Spanish instructions for creating new local skills, including naming, frontmatter, folder structure, and optional scripts/resources. | Covered by the system `skill-creator` skill and by root `AGENTS.md`, which already defines local skill rules. | Yes. It is redundant and slightly less aligned with the current rule to keep skills instruction-only unless scripts are explicitly requested. | No, unless the project specifically wants Spanish-only local skill authoring docs. | KEEP DELETED |
| `.agents/skills/ingeniero-rendimiento-android/SKILL.md` | Focused on Android performance: startup time, memory, CPU, battery, rendering, jank, and low-end device behavior. | Partially covered by `estabilidad-android-flutter`, `expense-qa-bug-hunter`, and `expense-release-finisher`, but not as a dedicated performance specialist. | Yes for cleanup and first release preparation. Performance is not the immediate blocker. | Yes, if profiling or low-end Android performance becomes a dedicated phase. | RESTORE LATER |
| `.agents/skills/optimizador-talla-android/SKILL.md` | Focused on APK/AAB size reduction, assets, dependency weight, R8/ProGuard, and Play delivery size. | Partially covered by `auditor-dependencias-flutter`, `seguridad-android-play`, and `expense-release-finisher`, but not as a dedicated size optimizer. | Yes for cleanup. Bundle size is not yet proven to be a release blocker. | Yes, if the release AAB is too large or Play/internal testing flags size concerns. | RESTORE LATER |
| `.agents/skills/traductor-elite-profesional/SKILL.md` | Provided high-quality English/Spanish translation guidance for UI text, store copy, changelogs, and localization files. | Partially covered by `expense-ui-ux` and `expense-release-finisher`, which can review app text and release copy. | Yes. Translation quality matters, but the skill is not required before cleanup. | Possible, but only if localization becomes a dedicated workflow. | OPTIONAL / NO EFFECT |
| `.agents/skills/traductor-tecnico-software/SKILL.md` | Provided technical English/Spanish translation guidance for docs, commands, code comments, and technical UI terms. | Partially covered by normal Codex behavior, `expense-release-finisher`, and `expense-ui-ux`. | Yes. It has no effect on app cleanup or release blockers. | Possible, but only if technical documentation translation becomes a separate task. | OPTIONAL / NO EFFECT |

## 4. Coverage by current skill setup

The current setup is enough for release preparation:

- Skill creation safety: covered by `AGENTS.md` and system `skill-creator`.
- Architecture and structure: covered by `arquitectura-flutter-simple` and `expense-architecture-auditor`.
- Dependencies and SDK risk: covered by `auditor-dependencias-flutter`.
- Financial logic: covered by `auditor-flujos-financieros` and `expense-financial-logic`.
- Stability and QA: covered by `estabilidad-android-flutter` and `expense-qa-bug-hunter`.
- UX and localization review: covered by `ux-fintech-simple`, `expense-ui-ux`, and `expense-release-finisher`.
- Android/Play security: covered by `seguridad-android-play`.
- Release completion: covered by `expense-release-finisher`.

The only capabilities not fully dedicated are Android performance profiling and AAB/APK size optimization. Those can be restored later after the app reaches a cleaner release baseline and after a release build is actually measured.

## 5. Any remaining workflow risk

Runtime risk: none. Deleted skill files do not affect the Flutter app, Android build, Firebase setup, calculations, or Play Console requirements.

Workflow risk: low. The decisions are now clear enough to stop treating these 5 deleted skills as blockers.

Repo cleanliness risk: still present until the dirty `.agents/skills/**` state is actually resolved in git. This review resolves the decision, not the working tree.

Capability risk: low. Dedicated performance and size optimization can be restored later if needed, but should not block app-source cleanup.

## 6. Whether skill deletion noise is resolved

Yes for planning and release-preparation decision making.

The skill deletion noise is resolved conceptually:

- 12 old skills can stay deleted.
- 1 manually reviewed skill can stay deleted.
- 2 manually reviewed skills are only restore-later candidates.
- 2 manually reviewed skills are optional/no effect.

The working tree will still show deleted `.agents/skills/**` files until the user explicitly accepts or applies the cleanup decision.

## 7. Exact safe next action

Proceed to resolve the agent setup as a separate non-app cleanup decision:

1. Accept the current focused skill setup.
2. Keep the deleted old skills deleted, with `ingeniero-rendimiento-android` and `optimizador-talla-android` documented as restore-later options.
3. Do not restore old skills before app-source cleanup unless the user specifically wants those optional capabilities now.
4. After that, move to app-source cleanup starting with the isolated auth/cloud chain and the isolated currency/calculation chain.
