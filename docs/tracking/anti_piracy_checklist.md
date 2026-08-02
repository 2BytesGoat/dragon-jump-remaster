---
title: Anti-Piracy Checklist
tags: [security, anti-piracy, export, release, tracking]
related:
  - "[[tracking/decisions]]"
  - "[[direction/release_plan]]"
  - "[[systems/architecture]]"
search_terms: [anti-piracy, drm, encryption, pck, export, clone, private-repo]
---

# Anti-Piracy Checklist

Threat model: someone downloads the itch web build, extracts the `.pck`,
gets all assets/scenes/scripts in original format, reconstructs the project,
adds AdMob, reuploads to mobile stores. Goal: raise extraction effort from
5 minutes to several hours per build, with zero online dependency.

## Audit — what's already in place (verified 2026-08-02)

### Done
- [x] Custom Windows export template with PCK key baked in (`custom-templates` GitHub release, `windows.zip`)
- [x] `GODOT_PCK_ENCRYPTION_KEY` CI secret wired to Windows export step (`.github/workflows/build-and-publish.yml:123`)
- [x] `encrypt_directory=true` on all three presets (script bytecode encryption) — `export_presets.cfg:22,94,144`
- [x] Save file: HMAC-SHA256 + constant-time compare + tamper tests pass (`save_manager.gd`, `test_save_security.gd`)
- [x] `runtime_secrets.gd` build-time injection (`.github/workflows/build-and-publish.yml:72-80`, gitignored)
- [x] `TelemetrySystem` local-only (`_send_remote` is no-op, `enable_remote` defaults false)

### Half-done (wired but inactive)
- [x] `encrypt_pck=true` on preset.0 (Windows) — custom template + key already exist (`export_presets.cfg:21`)
- [ ] No `web.zip` / `linux.zip` in `custom-templates` release → Web/Linux can't use PCK encryption yet

### Not done (verified absent)
- [x] Application metadata filled on all presets (company_name, copyright, trademarks, file_version, product_version) — `export_presets.cfg:41-51,101-107,158-164`
- [x] `binary_format/embed_pck=true` on Linux preset — `export_presets.cfg:166`
- [x] `script_export_mode=2` on all three presets — `export_presets.cfg:23,95,152`
- [x] `GODOT_SCRIPT_ENCRYPTION_KEY` env added to Web (lines 117-119) and Linux (lines 130-132) export steps
- [ ] No `BUILD_ID` constant anywhere; `runtime_secrets.gd.template` has no `BUILD_ID` field
- [ ] No attribution splash, origin_lock, piracy screen, custom HTML shell, or watermarking

## Phase 1 — Free config wins (done)

- [x] `export_presets.cfg` preset.0 (Windows): `encrypt_pck=false` → `true`
- [x] `export_presets.cfg` preset.1 (Web): `script_export_mode=1` → `2`
- [x] `export_presets.cfg` preset.2 (Linux): `binary_format/embed_pck=false` → `true`
- [x] `export_presets.cfg` preset.2 (Linux): `script_export_mode=1` → `2`
- [x] Fill `application/company_name`, `product_name`, `copyright`, `trademarks`, `file_version`, `product_version` on all three presets
- [x] `.github/workflows/build-and-publish.yml`: add `GODOT_SCRIPT_ENCRYPTION_KEY: ${{ secrets.GODOT_PCK_ENCRYPTION_KEY }}` env to Web export step (lines 116-119) and Linux export step (lines 128-131) for future-proofing
- [ ] Verify: export all three builds from CI, confirm they boot and play (local Godot not installed; verify via next CI run)

## Phase 2 — Custom Web template + PCK encryption for web (the big one)

The web build is the itch build and doubles as the arcade build. Most exposed target.

- [ ] Clone Godot 4.6 source, build Web `template_release` with same PCK key: `scons platform=web target=template_release production=yes script_encryption_key=<32-byte-hex>` (key must match `GODOT_PCK_ENCRYPTION_KEY` in GitHub secrets)
- [ ] Package output as `web.zip` (Godot web template is a zip of WASM + JS + HTML)
- [ ] Upload `web.zip` to the existing `custom-templates` GitHub release alongside `windows.zip`
- [ ] `.github/workflows/build-and-publish.yml`: add step after "Install Official Export Templates" (line 95) that downloads `web.zip` from `custom-templates` release and replaces the official web template in `~/.local/share/godot/export_templates/4.6.stable/` (mirror the Windows injection pattern at lines 97-114)
- [ ] `export_presets.cfg` preset.1 (Web): `encrypt_pck=false` → `true`
- [ ] Verify: export web build from CI, load on itch.io, confirm boots and plays
- [ ] Verify: load same web build on the arcade machine, confirm it works (origin-lock must not break arcade — see Phase 4)

## Phase 3 — Build-ID + attribution splash (~1 hr)

- [ ] `src/scripts/singletons/runtime_secrets.gd.template`: add `var BUILD_ID := "DEV"` field
- [ ] `.github/workflows/build-and-publish.yml`: in "Inject runtime secrets" step (lines 72-80), add `const BUILD_ID = "${{ steps.meta.outputs.tag }}"` to the generated `runtime_secrets.gd`
- [ ] Create `src/ui/menus/attribution_splash.tscn` + `.gd`: full-screen ColorRect + Label "Dragon Jump Remaster — play at 2bytesgoat.itch.io/dragon-jump. Playing elsewhere? It's a stolen copy." + smaller "Build ${BUILD_ID}" label, auto-fade ~1.5s, transition to main menu
- [ ] `main.gd`: route boot through attribution splash → main menu. Skip on arcade builds via build flag (e.g. `RuntimeSecrets.BUILD_ID == "ARCADE"` or separate `IS_ARCADE` constant)
- [ ] Optional: persist `user://attribution_shown_<build_id>` flag so splash shows once per build, not every launch

## Phase 4 — Origin-lock for web build (~30 min)

- [ ] Create `src/scripts/singletons/origin_lock.gd` (or function in `main.gd`): if `OS.has_feature("web")`, read `JavaScriptBridge.eval("window.location.hostname", true)`, check against `["itch.io", "html-classic.itch.zone", "html.itch.zone"]`, mismatch → `change_scene_to_file("res://src/ui/menus/piracy_screen.tscn")`. Desktop builds skip via `OS.has_feature` check.
- [ ] Create `src/ui/menus/piracy_screen.tscn` + `.gd`: full-screen "This is a pirated copy. Play the official version at 2bytesgoat.itch.io/dragon-jump." with no way to proceed.
- [ ] Wire origin_lock into boot sequence (after attribution splash, before main menu)
- [ ] Verify arcade machine (loads from itch.io) passes the origin-lock — must not break the arcade build

## Phase 5 — Custom HTML shell + watermarking (~1 hr)

- [ ] Create `export/web/custom_shell.html` — stripped/minified version of Godot's default web shell (start from `misc/dist/html/` in Godot source). Remove branding/comments, minify JS bootstrapping.
- [ ] `export_presets.cfg` preset.1 (Web): set `html/custom_html_shell="res://export/web/custom_shell.html"` (currently empty at line 106)
- [ ] Pick one `.tres` resource (e.g. `resources/physics_params.tres`), embed build-ID as comment or unused field — forensic watermark for DMCA provenance
- [ ] Optional: add 1px or near-invisible per-build pattern in corner of title screen background texture (varies by build-ID hash)

## Repo visibility decision

**Recommendation: flip to private before launch.** With 0 stars/forks/subscribers there is no social cost now. Public source acts as a decoder ring for anyone decompiling the encrypted builds (scene names, autoloads, signals all match). Going private forces attackers to decompile blind.

- [ ] Before flipping: audit any public links (itch page, portfolio, social) pointing at `github.com/2BytesGoat/dragon-jump-remaster` — they break for logged-out viewers once private
- [ ] Before flipping: fix README scope claim "macOS" — CI says "MacOS build is no longer supported" (mismatched public surface)
- [ ] Flip repo to private (GitHub repo settings → Change visibility)
- [ ] After flipping: trigger `workflow_dispatch` CI run, verify Windows export still succeeds (`GODOT_PCK_ENCRYPTION_KEY` + `custom-templates` release both work on private repos; `gh release download` uses `${{ github.token }}`)
- [ ] Optional: create separate public `dragon-jump-remaster-press` repo or GitHub Pages site with screenshots/devlog/press kit to replace discoverability

## Explicitly deferred (revisit post-launch if needed)

- Linux desktop PCK encryption — Steam Linux users use Proton; arcade runs web build. Low priority.
- Mac support — deferred.
- Provenance ping (Tier 3) — user opted for fully offline.
- Legal/DMCA docs (copyright registration, trademark, takedown playbook) — deferred; EULA already in place.
- C# rewrite — IL decompiles as cleanly as GDScript, doesn't help against asset theft.
- GDExtension rewrite of gameplay — protects code only, not assets; threat model is asset theft.
