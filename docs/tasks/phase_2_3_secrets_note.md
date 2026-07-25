# Phase 2.3 — Required GitHub Secret Reminder

Phase 2.3 changed the CI pipeline to inject a real HMAC signing key into
`src/scripts/singletons/runtime_secrets.gd` during exported builds.

## Secret you MUST add

- Name: `SAVE_HMAC_SECRET`
- Location: GitHub repo → Settings → Secrets and variables → Actions → New repository secret
- Value: any long, random string (e.g. `openssl rand -hex 32`)

## Why it matters

`SaveManager` signs save files with HMAC-SHA256. In local/editor builds it uses a
harmless fallback (`"CHANGE_ME_IN_BUILD_PIPELINE"`). In CI/exported builds the
fallback is replaced with this secret. If the secret is missing, the build fails
on purpose with a clear error.

## Keep it stable

- Do **not** change `SAVE_HMAC_SECRET` after releasing a public build.
- Changing it invalidates existing player saves (they will be rejected as tampered
  and reset to a fresh save).
- Back it up somewhere safe (password manager, etc.).

## Secrets no longer used

The workflow no longer reads these, so they can be deleted from GitHub if desired:

- `SILENT_WOLF_API_KEY`
- `SILENT_WOLF_GAME_ID`

They are left as no-op placeholders in `runtime_secrets.gd` in case SilentWolf is
integrated later.