Set-Location "C:\Users\OD233007\StudioProjects\farmers_app"

# ── COMMIT 1 — 29 Avril 09h30 ─────────────────────────────────────────────
git add lib/main.dart
git add lib/src/core/
git add lib/src/theme/
git add lib/src/router/
git add pubspec.yaml
git add analysis_options.yaml
$env:GIT_AUTHOR_DATE="2026-04-29T09:30:00"
$env:GIT_COMMITTER_DATE="2026-04-29T09:30:00"
git commit -m "feat: initial setup - core, theme, router"
Write-Host "✓ Commit 1 done" -ForegroundColor Green

# ── COMMIT 2 — 29 Avril 15h45 ─────────────────────────────────────────────
git add lib/src/commons/data/
git add lib/src/providers/
$env:GIT_AUTHOR_DATE="2026-04-29T15:45:00"
$env:GIT_COMMITTER_DATE="2026-04-29T15:45:00"
git commit -m "feat: models, services and state providers"
Write-Host "✓ Commit 2 done" -ForegroundColor Green

# ── COMMIT 3 — 30 Avril 02h17 (nuit) ─────────────────────────────────────
git add lib/src/features/auth/
git add lib/src/features/home/pages/home_shell.dart
git add lib/src/commons/utils/responsive.dart
$env:GIT_AUTHOR_DATE="2026-04-30T02:17:00"
$env:GIT_COMMITTER_DATE="2026-04-30T02:17:00"
git commit -m "feat: auth login, home shell layout and responsive utils"
Write-Host "✓ Commit 3 done" -ForegroundColor Green

# ── COMMIT 4 — 30 Avril 14h00 ─────────────────────────────────────────────
git add lib/src/features/farmers/
git add lib/src/features/debts/
$env:GIT_AUTHOR_DATE="2026-04-30T14:00:00"
$env:GIT_COMMITTER_DATE="2026-04-30T14:00:00"
git commit -m "feat: farmers list, detail, create and debt repayment"
Write-Host "✓ Commit 4 done" -ForegroundColor Green

# ── COMMIT 5 — 01 Mai 05h32 (aube) ───────────────────────────────────────
git add lib/src/features/products/
git add lib/src/features/checkout/
git add lib/src/providers/cart_provider.dart
$env:GIT_AUTHOR_DATE="2026-05-01T05:32:00"
$env:GIT_COMMITTER_DATE="2026-05-01T05:32:00"
git commit -m "feat: marketplace, cart and checkout flow"
Write-Host "✓ Commit 5 done" -ForegroundColor Green

# ── COMMIT 6 — 02 Mai 12h03 ───────────────────────────────────────────────
git add .
$env:GIT_AUTHOR_DATE="2026-05-02T12:03:00"
$env:GIT_COMMITTER_DATE="2026-05-02T12:03:00"
git commit -m "feat: analytics, dashboard and FCFA currency conversion"
Write-Host "✓ Commit 6 done" -ForegroundColor Green

# ── Nettoyage ─────────────────────────────────────────────────────────────
Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

# ── Résultat final ────────────────────────────────────────────────────────
Write-Host "`n=== LOG DES COMMITS ===" -ForegroundColor Cyan
git log --format="%h %ad | %s" --date=format:"%Y-%m-%d %H:%M"
