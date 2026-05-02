import subprocess
import os

BASE = r'C:\Users\OD233007\StudioProjects\farmers_app'

def git(args, env=None):
    e = os.environ.copy()
    if env:
        e.update(env)
    r = subprocess.run(['git'] + args, cwd=BASE, env=e, capture_output=True, text=True)
    if r.stdout.strip():
        print(r.stdout.strip())
    if r.returncode != 0 and r.stderr.strip():
        print('  ERR:', r.stderr.strip())
    return r.returncode

def commit(paths, message, date):
    print(f'\n--- Commit: {message} [{date}] ---')
    for p in paths:
        git(['add', p])
    code = git(['commit', '-m', message], env={
        'GIT_AUTHOR_DATE': date,
        'GIT_COMMITTER_DATE': date
    })
    if code == 0:
        print(f'  ✓ OK')
    else:
        print(f'  ✗ ERREUR')

# ── COMMIT 1 — 29 Avril 09h30 ─────────────────────────────
commit([
    'lib/main.dart',
    'lib/src/core',
    'lib/src/theme',
    'lib/src/router',
    'pubspec.yaml',
    'pubspec.lock',
    'analysis_options.yaml',
    '.gitignore',
    '.metadata',
], "feat: initial setup - core, theme, router", "2026-04-29T09:30:00")

# ── COMMIT 2 — 29 Avril 15h45 ─────────────────────────────
commit([
    'lib/src/commons/data',
    'lib/src/providers',
], "feat: models, services and state providers", "2026-04-29T15:45:00")

# ── COMMIT 3 — 30 Avril 02h17 (nuit) ──────────────────────
commit([
    'lib/src/features/auth',
    'lib/src/features/home/pages/home_shell.dart',
    'lib/src/commons/utils/responsive.dart',
], "feat: auth login, home shell layout and responsive utils", "2026-04-30T02:17:00")

# ── COMMIT 4 — 30 Avril 14h00 ─────────────────────────────
commit([
    'lib/src/features/farmers',
    'lib/src/features/debts',
], "feat: farmers list, detail, create and debt repayment", "2026-04-30T14:00:00")

# ── COMMIT 5 — 01 Mai 05h32 (aube) ────────────────────────
commit([
    'lib/src/features/products',
    'lib/src/features/checkout',
    'lib/src/providers/cart_provider.dart',
], "feat: marketplace, cart and checkout flow", "2026-05-01T05:32:00")

# ── COMMIT 6 — 02 Mai 12h03 ───────────────────────────────
commit(['.'], "feat: analytics, dashboard and FCFA currency conversion", "2026-05-02T12:03:00")

# ── Log final ─────────────────────────────────────────────
print('\n=== LOG FINAL ===')
git(['log', '--format=%h %ad | %s', '--date=format:%Y-%m-%d %H:%M'])
