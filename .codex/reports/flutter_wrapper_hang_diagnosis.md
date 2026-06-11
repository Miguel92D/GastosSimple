# Flutter Wrapper Hang Diagnosis

## 1. Executive summary

The hang is in the Flutter wrapper/bootstrap layer, not in the Dart SDK executable itself.

Observed behavior:

- `C:\flutter\bin\cache\dart-sdk\bin\dart.exe --suppress-analytics --version` returns immediately.
- `C:\flutter\bin\dart.bat --version` times out.
- `C:\flutter\bin\flutter.bat --version` times out.

The wrapper path goes through `C:\flutter\bin\internal\shared.bat`, which:

- checks for Git
- computes the Flutter engine version through PowerShell helpers
- acquires `C:\flutter\bin\cache\flutter.bat.lock`
- refreshes cache artifacts such as `engine.stamp`, `engine.realm`, `flutter_tools.snapshot`, and `flutter_tools.stamp`

The strongest evidence points to a cache/bootstrap failure caused by inaccessible Flutter cache artifacts under `C:\flutter\bin\cache`, with Git safe-directory rejection also present under this sandbox identity. The wrappers appear to be caught in retry/bootstrapping paths rather than reaching Dart and exiting normally.

No application source files were touched and no app validation was run.

## 2. Wrapper files/scripts inspected

Inspected wrapper entry points:

- `C:\flutter\bin\dart.bat`
- `C:\flutter\bin\flutter.bat`
- `C:\flutter\bin\internal\shared.bat`
- `C:\flutter\bin\internal\exit_with_errorlevel.bat`

Inspected helper scripts used by the wrapper bootstrap path:

- `C:\flutter\bin\internal\update_engine_version.ps1`
- `C:\flutter\bin\internal\update_dart_sdk.ps1`
- `C:\flutter\bin\internal\content_aware_hash.ps1`
- `C:\flutter\bin\internal\shared.sh`
- `C:\flutter\bin\internal\update_engine_version.sh`
- `C:\flutter\bin\internal\update_dart_sdk.sh`
- `C:\flutter\bin\internal\content_aware_hash.sh`

Relevant runtime commands resolved:

- `dart` resolves to `C:\flutter\bin\dart.bat`
- `flutter` resolves to `C:\flutter\bin\flutter.bat`
- `git` resolves to `C:\Program Files\Git\cmd\git.exe`

## 3. Commands run

Report reads:

```powershell
Get-Content -Raw .codex/reports/dart_tooling_cleanup_applied.md
Get-Content -Raw .codex/reports/dart_tooling_diagnosis.md
```

Wrapper and helper inspection:

```powershell
Get-Content C:\flutter\bin\dart.bat
Get-Content C:\flutter\bin\flutter.bat
Get-Content C:\flutter\bin\internal\shared.bat
Get-Content C:\flutter\bin\internal\exit_with_errorlevel.bat
Get-Content C:\flutter\bin\internal\update_engine_version.ps1
Get-Content C:\flutter\bin\internal\update_dart_sdk.ps1
Get-Content C:\flutter\bin\internal\content_aware_hash.ps1
Get-Content C:\flutter\bin\internal\shared.sh
Get-Content C:\flutter\bin\internal\update_engine_version.sh
Get-Content C:\flutter\bin\internal\update_dart_sdk.sh
Get-Content C:\flutter\bin\internal\content_aware_hash.sh
```

PATH and command resolution:

```powershell
Get-Command dart | Format-List Source,Path,CommandType,Definition
Get-Command flutter | Format-List Source,Path,CommandType,Definition
where.exe dart
where.exe flutter
Get-Command git | Format-List Source,Path,CommandType,Definition
where.exe git
```

Environment inspection:

```powershell
Get-ChildItem Env: | Where-Object { $_.Name -match '^(FLUTTER|DART|PUB|CI|BOT|CHROME|GIT|PATH|TEMP|TMP|HOME|USERPROFILE|LOCALAPPDATA|APPDATA|PROCESSOR_ARCHITECTURE|PROCESSOR_ARCHITEW6432)$' } | Sort-Object Name | Format-Table -AutoSize
```

Direct behavior comparisons:

```powershell
dart --version
flutter --version
C:\flutter\bin\cache\dart-sdk\bin\dart.exe --suppress-analytics --version
```

Git and helper diagnostics:

```powershell
git --version
git rev-parse HEAD
git -C C:\flutter rev-parse --abbrev-ref HEAD
git -C C:\flutter ls-files bin/internal/engine.version
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\flutter\bin\internal\update_engine_version.ps1
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\flutter\bin\internal\content_aware_hash.ps1
```

Sandbox-safe Git override tests:

```powershell
$env:GIT_CONFIG_COUNT='1'; $env:GIT_CONFIG_KEY_0='safe.directory'; $env:GIT_CONFIG_VALUE_0='C:/flutter'; cmd /d /c "C:\flutter\bin\dart.bat --version"
$env:GIT_CONFIG_COUNT='1'; $env:GIT_CONFIG_KEY_0='safe.directory'; $env:GIT_CONFIG_VALUE_0='C:/flutter'; cmd /d /c "C:\flutter\bin\flutter.bat --version"
$env:GIT_CONFIG_COUNT='1'; $env:GIT_CONFIG_KEY_0='safe.directory'; $env:GIT_CONFIG_VALUE_0='C:/flutter'; PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\flutter\bin\internal\update_engine_version.ps1
$env:GIT_CONFIG_COUNT='1'; $env:GIT_CONFIG_KEY_0='safe.directory'; $env:GIT_CONFIG_VALUE_0='C:/flutter'; PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\flutter\bin\internal\content_aware_hash.ps1
```

Cache and ACL inspection:

```powershell
Get-Acl C:\flutter\bin\cache | Format-List Path,Owner,AccessToString,AuditToString,AreAccessRulesProtected,AreAuditRulesProtected
Get-Acl C:\flutter | Format-List Path,Owner,AccessToString,AuditToString,AreAccessRulesProtected,AreAuditRulesProtected
Get-Item C:\flutter\bin\cache\engine.stamp | Format-List FullName,Length,LastWriteTime,Attributes
$paths = @('C:\flutter\bin\cache\engine.stamp','C:\flutter\bin\cache\engine.realm','C:\flutter\bin\cache\flutter_tools.snapshot','C:\flutter\bin\cache\flutter_tools.stamp')
```

Live process probe:

```powershell
$p = Start-Process -WindowStyle Hidden -FilePath cmd.exe -ArgumentList '/d /c "C:\flutter\bin\dart.bat --version"' -PassThru
Start-Sleep -Seconds 3
Get-Process | Where-Object { $_.Id -eq $p.Id -or $_.ProcessName -match 'cmd|powershell|pwsh|git|dart|conhost' } | Select-Object Id,ProcessName,StartTime,Path -ErrorAction SilentlyContinue
```

## 4. Observed behavior by command path

PATH resolution:

- `dart` resolves to `C:\flutter\bin\dart.bat`
- `flutter` resolves to `C:\flutter\bin\flutter.bat`
- No PATH shadowing issue was found.

Direct Dart SDK executable:

- `C:\flutter\bin\cache\dart-sdk\bin\dart.exe --suppress-analytics --version` succeeds immediately.
- This shows the SDK binary itself is healthy.

Wrapper entry points:

- `dart --version` times out.
- `flutter --version` times out.
- A background probe confirmed the wrapper `cmd.exe` process remains alive after several seconds instead of exiting quickly.

Git behavior in `C:\flutter`:

- `git rev-parse HEAD` works in the current repo.
- `git -C C:\flutter rev-parse --abbrev-ref HEAD` fails with Git dubious-ownership/safe-directory rejection under the sandbox identity.
- `content_aware_hash.ps1` succeeds when `safe.directory` is injected for `C:/flutter`.

PowerShell helper behavior:

- `update_engine_version.ps1` fails when it tries to write `C:\flutter\bin\cache\engine.stamp`.
- `content_aware_hash.ps1` succeeds with `safe.directory` injected and returns a hash.

Cache artifact behavior:

- These files are not openable for exclusive read/write in this sandbox session:
  - `C:\flutter\bin\cache\engine.stamp`
  - `C:\flutter\bin\cache\engine.realm`
  - `C:\flutter\bin\cache\flutter_tools.snapshot`
  - `C:\flutter\bin\cache\flutter_tools.stamp`
- The ACLs show write-capable entries on `C:\flutter` and `C:\flutter\bin\cache`, so the denial is not explained by the visible ACL alone.

## 5. Most likely root cause

The wrapper hang is most likely caused by the Flutter bootstrap layer repeatedly hitting inaccessible or locked cache artifacts in `C:\flutter\bin\cache`, with a secondary Git safe-directory rejection under the sandbox identity.

More specifically:

- `shared.bat` invokes PowerShell helpers before Dart starts.
- `update_engine_version.ps1` cannot write `engine.stamp`.
- `content_aware_hash.ps1` and `git` fail on `C:\flutter` unless `safe.directory` is injected.
- `flutter.bat` then has additional bootstrapping and pub-upgrade work on top of the same cache state.

This fits the observed timeout pattern far better than PATH shadowing or a broken `dart.exe`.

## 6. Evidence for that root cause

Evidence against PATH shadowing:

- `Get-Command dart` and `Get-Command flutter` resolve directly to the Flutter batch files.
- `where.exe` confirms the same resolution.
- Direct `dart.exe` works immediately.

Evidence for bootstrap/cache failure:

- `dart.bat` and `flutter.bat` both call `shared.bat`.
- `shared.bat` acquires `flutter.bat.lock`, updates engine artifacts, and may retry failed bootstrap steps.
- The lock files were removed in the previous cleanup pass, but the wrappers still timed out afterward.
- A live process probe showed the wrapper `cmd.exe` staying alive.
- `update_engine_version.ps1` fails on `Set-Content C:\flutter\bin\cache\engine.stamp`.
- The key Flutter cache artifacts are not openable with exclusive read/write access from this session.

Evidence for the Git/safe-directory contribution:

- `git -C C:\flutter rev-parse --abbrev-ref HEAD` fails with a dubious-ownership message.
- The same helper scripts succeed when `safe.directory=C:/flutter` is injected for the command.
- That means the wrapper bootstrap path is also sensitive to repository ownership/trust policy in this environment.

Evidence against a broken Dart SDK:

- `C:\flutter\bin\cache\dart-sdk\bin\dart.exe --suppress-analytics --version` returns immediately and reports `Dart SDK version: 3.11.1`.

## 7. Safe tooling-only fixes to try next, in order

1. Make `C:\flutter` trusted for Git in this sandbox/session, at least temporarily, so the wrapper bootstrap scripts can complete their Git checks without the dubious-ownership rejection.
2. Investigate what is holding `C:\flutter\bin\cache\engine.stamp`, `engine.realm`, `flutter_tools.snapshot`, and `flutter_tools.stamp` open or inaccessible.
3. Re-run the wrapper version commands after the cache artifact access issue is cleared.
4. Only if wrappers start returning, retry `flutter pub get` to restore package resolution.

## 8. Whether a tiny tooling-only change was applied

No.

No persistent config, script, or repo file was changed in this pass. The `safe.directory` value was only injected temporarily inside diagnostic commands.

## 9. Whether wrapper commands can be recovered safely

Yes, but not by touching app code.

Recovery appears feasible if the cache artifact access issue and Git trust issue are cleared in tooling/environment only. The current failure mode is outside application logic.

## 10. Exact next safe action

Run a tooling-only recovery check focused on the Flutter cache artifacts:

1. Temporarily make `C:\flutter` trusted for Git in the active session.
2. Re-test exclusive read/write access to `C:\flutter\bin\cache\engine.stamp` and `C:\flutter\bin\cache\flutter_tools.snapshot`.
3. Re-run `C:\flutter\bin\dart.bat --version` and `C:\flutter\bin\flutter.bat --version`.

Do not move into app validation until both wrapper commands return cleanly.
