# Flutter Wrapper Recovery Pass 2

Date: 2026-05-11

## 1. Executive summary

Flutter wrapper recovery succeeded when the allowed wrapper commands were run outside the filesystem sandbox with temporary Git `safe.directory` for `C:/flutter`.

The direct blocker was not a real file lock in `C:\flutter\bin\cache`; outside the sandbox, all key cache artifacts were openable with exclusive read/write access. Inside the sandbox, those same artifacts reported access denied, which caused wrapper commands to hang before producing output.

No application source, business logic, Android release config, builds, tests, analyzers, or formatters were run.

## 2. Tooling-only actions applied

- Temporarily injected Git safe-directory only for the active command environment:
  - `GIT_CONFIG_COUNT=1`
  - `GIT_CONFIG_KEY_0=safe.directory`
  - `GIT_CONFIG_VALUE_0=C:/flutter`
- Re-tested cache artifact access outside the sandbox.
- Ran only the allowed wrapper verification commands:
  - `C:\flutter\bin\dart.bat --version`
  - `C:\flutter\bin\flutter.bat --version`
  - `C:\flutter\bin\flutter.bat pub get`
- No persistent Git config was changed.
- No Flutter SDK files were deleted or edited.

## 3. Commands run

Read required reports:

```powershell
Get-Content .codex\reports\debug_build_verbose_diagnosis.md
Get-Content .codex\reports\flutter_wrapper_hang_diagnosis.md
Get-Content .codex\reports\dart_tooling_cleanup_applied.md
Get-Content .codex\reports\dart_tooling_diagnosis.md
```

Checked current state:

```powershell
Get-Process | Where-Object { $_.ProcessName -match 'flutter|dart|gradle|cmd' }
git -C C:\flutter rev-parse --abbrev-ref HEAD
```

Checked Git with temporary safe-directory:

```powershell
$env:GIT_CONFIG_COUNT='1'
$env:GIT_CONFIG_KEY_0='safe.directory'
$env:GIT_CONFIG_VALUE_0='C:/flutter'
git -C C:\flutter rev-parse --abbrev-ref HEAD
```

Checked cache artifact access:

```powershell
[System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
```

Verified wrappers:

```powershell
C:\flutter\bin\dart.bat --version
C:\flutter\bin\flutter.bat --version
C:\flutter\bin\flutter.bat pub get
```

## 4. Cache artifact access results

Inside the sandbox, these paths still reported `Access denied` for exclusive read/write:

- `C:\flutter\bin\cache\engine.stamp`
- `C:\flutter\bin\cache\engine.realm`
- `C:\flutter\bin\cache\flutter_tools.snapshot`
- `C:\flutter\bin\cache\flutter_tools.stamp`
- `C:\flutter\bin\cache\flutter.bat.lock`
- `C:\flutter\bin\cache\lockfile`

Outside the sandbox, these key artifacts were openable with exclusive read/write:

- `C:\flutter\bin\cache\engine.stamp`
- `C:\flutter\bin\cache\engine.realm`
- `C:\flutter\bin\cache\flutter_tools.snapshot`
- `C:\flutter\bin\cache\flutter_tools.stamp`

Conclusion: cache permissions are a sandbox access blocker, not an active OS-level file lock.

## 5. Result of C:\flutter\bin\dart.bat --version

Succeeded.

Output:

```text
Dart SDK version: 3.11.1 (stable) (Tue Feb 24 00:03:07 2026 -0800) on "windows_x64"
```

## 6. Result of C:\flutter\bin\flutter.bat --version

Succeeded.

Output summary:

```text
Flutter 3.41.3, channel stable
Tools: Dart 3.11.1, DevTools 2.54.1
```

## 7. Result of C:\flutter\bin\flutter.bat pub get

Succeeded.

Output summary:

```text
Resolving dependencies...
Downloading packages...
Got dependencies!
63 packages have newer versions incompatible with dependency constraints.
```

No `pubspec.yaml` or `pubspec.lock` changes were reported by the focused git status check after `pub get`.

## 8. Whether Git safe-directory was a blocker

Yes.

Without temporary trust, Git still fails for `C:\flutter` with a dubious ownership error under the sandbox identity. With temporary `safe.directory=C:/flutter`, Git reports the Flutter channel as `stable`.

No persistent Git safe-directory entry was added in this pass.

## 9. Whether cache access/permissions were a blocker

Yes for sandboxed commands.

The cache files are accessible outside the sandbox, but sandboxed wrapper commands cannot open them for exclusive read/write. This explains why wrapper commands hung in earlier sandboxed attempts before emitting Flutter output.

## 10. Whether Flutter wrapper is now usable

Yes, when run outside the sandbox with temporary Git safe-directory for `C:/flutter`.

The wrapper is not proven usable from the default sandboxed command path because cache artifact access is still denied there.

## 11. Exact next safe action

Run the next diagnostic/build pass using the same tooling wrapper conditions:

1. Use temporary `safe.directory=C:/flutter` for the command environment.
2. Run Flutter commands outside the filesystem sandbox when they need to access `C:\flutter\bin\cache`.
3. Start with one debug build or analyzer pass only, then fix source compile blockers from that fresh output.
