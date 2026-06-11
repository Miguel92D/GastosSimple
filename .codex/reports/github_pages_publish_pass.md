# GitHub Pages publish pass

## 1. Executive summary

Prepared and committed the `$imple` GitHub Pages root files in a separate clone of `simple-app-ar/simple-app-ar.github.io` at `C:\tmp\simple-app-ar.github.io`, but the push did not succeed. GitHub rejected the push with HTTP 403 because the active credentials are for `Miguel92D`, which does not have permission to push to `simple-app-ar/simple-app-ar.github.io`.

The original app repository remote was not changed.

## 2. Source files published

Source files verified in the app repo:

- `github_pages_root/index.html`
- `github_pages_root/privacy.html`

Copied into the separate clone root as:

- `C:\tmp\simple-app-ar.github.io\index.html`
- `C:\tmp\simple-app-ar.github.io\privacy.html`

## 3. Target repository

- `https://github.com/simple-app-ar/simple-app-ar.github.io`
- Clone URL used: `https://github.com/simple-app-ar/simple-app-ar.github.io.git`
- Local clone: `C:\tmp\simple-app-ar.github.io`

## 4. Target public URL

- `https://simple-app-ar.github.io/privacy.html`

## 5. Commands run

Verification:

```powershell
Test-Path github_pages_root\index.html
Test-Path github_pages_root\privacy.html
rg -n -F '$imple' github_pages_root\index.html github_pages_root\privacy.html
rg -n -F 'GastosSimple' github_pages_root\index.html github_pages_root\privacy.html
rg -n -F 'Gastos Simple' github_pages_root\index.html github_pages_root\privacy.html
git remote -v
```

Publish attempt:

```powershell
git clone https://github.com/simple-app-ar/simple-app-ar.github.io.git C:\tmp\simple-app-ar.github.io
Copy-Item -LiteralPath C:\Users\MiguelD\Desktop\GastosSimple\github_pages_root\index.html -Destination C:\tmp\simple-app-ar.github.io\index.html -Force
Copy-Item -LiteralPath C:\Users\MiguelD\Desktop\GastosSimple\github_pages_root\privacy.html -Destination C:\tmp\simple-app-ar.github.io\privacy.html -Force
git add index.html privacy.html
git config user.name Miguel
git config user.email miguel@gastossimple.com
git commit -m 'Publish $imple privacy policy'
git push origin main
```

Commit created in the separate clone:

```text
8b00ce7 Publish $imple privacy policy
```

## 6. Push result

Push failed.

GitHub response:

```text
remote: Permission to simple-app-ar/simple-app-ar.github.io.git denied to Miguel92D.
fatal: unable to access 'https://github.com/simple-app-ar/simple-app-ar.github.io.git/': The requested URL returned error: 403
```

## 7. If push failed, exact manual fallback steps

Use an account/token with write access to `simple-app-ar/simple-app-ar.github.io`, then run:

```powershell
cd C:\tmp\simple-app-ar.github.io
git status
git log --oneline -1
git push origin main
```

If the local clone is removed or you prefer starting fresh:

```powershell
cd C:\tmp
git clone https://github.com/simple-app-ar/simple-app-ar.github.io.git simple-app-ar.github.io
Copy-Item -LiteralPath C:\Users\MiguelD\Desktop\GastosSimple\github_pages_root\index.html -Destination C:\tmp\simple-app-ar.github.io\index.html -Force
Copy-Item -LiteralPath C:\Users\MiguelD\Desktop\GastosSimple\github_pages_root\privacy.html -Destination C:\tmp\simple-app-ar.github.io\privacy.html -Force
cd C:\tmp\simple-app-ar.github.io
git add index.html privacy.html
git config user.name Miguel
git config user.email miguel@gastossimple.com
git commit -m 'Publish $imple privacy policy'
git push origin main
```

## 8. Exact next safe action

Authenticate Git with a GitHub user or token that has write access to `simple-app-ar/simple-app-ar.github.io`, then run `git push origin main` from `C:\tmp\simple-app-ar.github.io`.
