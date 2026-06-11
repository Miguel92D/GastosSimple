# Local-Only Release Behavior Checklist

Audit date: 2026-05-11

## 1. App starts without auth/cloud

- [x] `AuthService` is no longer registered in `main.dart`.
- [x] App startup does not depend on Google Sign-In UI or AuthService provider state.
- [ ] Run app smoke test after currency/calculation chain is resolved.

## 2. No sign-in entry point in release flow

- [x] Settings no longer shows "Cuenta Google".
- [x] Backup screen no longer shows Google sign-in.
- [x] `/auth` route is no longer registered in `AppRouter`.
- [x] `AppRoutes.auth` was removed.

## 3. No cloud restore entry point in release flow

- [x] No cloud restore UI was added or exposed.
- [x] Existing Backup screen restore remains local file restore.
- [x] `CloudBackupService.restoreBackup()` is not reachable from normal release UI.

## 4. Local backup still behaves correctly, if present

- [x] Local export button remains in Backup screen.
- [x] Local restore button remains in Backup screen.
- [ ] Manual export/import smoke test still needed.

## 5. Settings screen stays coherent

- [x] Backup section still points to local backup screen.
- [x] Google account entry was removed.
- [ ] Visual check still needed because Settings had unrelated dirty UI changes before this pass.

## 6. No dead buttons or broken routes from this cleanup

- [x] Normal release navigation no longer points to `/auth`.
- [x] Backup cloud button was removed instead of left disabled.
- [x] Transaction auto-backup calls were removed.
- [ ] Run analyzer after remaining dirty calculation chain is resolved.
