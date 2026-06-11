# Auth / Cloud Chain Status

Audit date: 2026-05-11

## 1. Files in chain

| File | Current dirty status | Prior decision | Decision applied in this pass |
| --- | --- | --- | --- |
| `lib/core/router/app_router.dart` | modified | ISOLATE | Isolated in report; left untouched |
| `lib/core/router/app_routes.dart` | modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/settings/screens/backup_screen.dart` | modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/settings/screens/settings_screen.dart` | modified | ISOLATE | Isolated in report; left untouched |
| `lib/main.dart` | modified | ISOLATE | Isolated in report; left untouched |
| `lib/services/cloud_backup_service.dart` | modified | ISOLATE | Isolated in report; left untouched |
| `lib/features/auth/screens/auth_screen.dart` | untracked | ISOLATE | Isolated in report; left untouched |
| `lib/services/auth_service.dart` | untracked | ISOLATE | Isolated in report; left untouched |
| `lib/firebase_options.dart` | modified | REVIEW | Left untouched |
| `ios/Runner/GoogleService-Info.plist` | untracked | REVIEW | Left untouched |

## 2. Decision applied per file

- `ISOLATE` files were not reverted because the prior reports did not classify them as safe to discard.
- `REVIEW` files were left untouched as required.
- No auth/cloud file was edited, renamed, staged, deleted, or restored.

## 3. What was changed

Only this report and the pass summary report were created. No auth/cloud source file was changed.

## 4. What remains risky

- Google sign-in route and UI are present in dirty files but account deletion/data deletion is missing.
- Backup screen exposes cloud backup while cloud restore remains incomplete.
- Settings exposes Google account behavior that changes Play policy obligations.
- `main.dart` registers `AuthService`, making auth part of app runtime if the dirty changes are kept.
- `cloud_backup_service.dart` stores user metadata and uploads transaction/vault data, but deletion/restore/privacy alignment is unresolved.
- `firebase_options.dart` and the iOS plist need platform identity review but are not safe to force one way in this pass.

## 5. Whether this chain is now safe enough to continue

No.

This chain is safe enough to discuss as one isolated unit, but not safe enough for release fixes. The next step must be a product decision:

- hide/revert auth-cloud exposure for the first release, or
- keep the full chain and complete privacy, account deletion, cloud data deletion, and restore behavior before Play release.
