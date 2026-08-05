# Repository Review Notes — 2026-08-02

> [!NOTE]
> This is a historical snapshot from 2026-08-02. Several issues identified here
> have been addressed by the docs restructure on 2026-08-05:
> - **Item 4** (phantom files in tracking) — pruned in `docs/meta/tracking.md`
> - **Item 5** (stale `other_scripts.md`) — rewritten as `docs/technical/utilities.md`
> - **Item 6** (leaderboard docs) — updated with V1.0 stub note in `docs/technical/leaderboard.md`
> - **Item 8** (duplicate docs trees) — legacy `docs/*_system/` directories removed; all content now in `docs/technical/`
> - **Item 9** (typo in filename) — fixed: now `docs/technical/save-system/campaign-level-data.md`
>
> Items still open: #1 (RuntimeSecrets autoload), #2-3 (README issues), #7 (autoload roster mismatch), #10-11 (README polish).

Review of the repository, its docs, and project config. Findings are grouped by
severity. Each item lists the concrete location and a recommended action.

---

## Critical — project will not load from a fresh clone

### 1. `RuntimeSecrets` autoload registered but file is missing
- `project.godot` registers `RuntimeSecrets="*res://src/scripts/singletons/runtime_secrets.gd"`.
- `.gitignore` excludes `src/scripts/singletons/runtime_secrets.gd` (intentional — secrets are injected at build time).
- However, the `.gd` file is never generated in the repo, so a fresh clone
  **cannot open in the Godot editor** — the autoload will fail to resolve.
- **Fix options:**
  - Add a committed `runtime_secrets.gd.template` with empty/default values and
    document the copy step in README (e.g. `cp src/scripts/singletons/runtime_secrets.gd.template src/scripts/singletons/runtime_secrets.gd`).
  - Or make the autoload optional: guard references in code so the project
    loads even when the file is absent, and register the autoload via a build
    step only.
- Related: `docs/systems/other_scripts/other_scripts.md` documents
  `runtime_secrets.gd` with `SILENT_WOLF_API_KEY` / `SILENT_WOLF_GAME_ID`
  properties, but the actual file is unversioned, so the doc is unverifiable.

---

## High — broken/stale references in README

### 2. README references `tools/graphify_godot_bridge.py` which does not exist
- `README.md` lines 31–52 instruct running
  `python3 tools/graphify_godot_bridge.py` and
  `graphify extract graphify-bridge ...`.
- There is no `tools/` directory in the repo, no
  `graphify_godot_bridge.py` file, and no `graphify-bridge/` output.
- **Fix:** either add the tool and a `tools/` entry, or remove the entire
  "Graphify + Godot bridge" section from README until the tool is committed.

### 3. README scope contradicts docs
- README's "Release plan" lists co-op/bot race, 20 practice maps, loading maps
  from friends, leaderboards, online multiplayer, map editor, custom game modes.
- `docs/direction/release_plan.md` explicitly locks V1.0 to a **single-player**
  arcade speedrun platformer with multiplayer/editor/online leaderboards
  **out of scope**.
- The README is selling a vision that the design docs have cut. This is the
  #34 backlog item ("Update top-level README for arcade + V1.0 scope") but it
  remains unresolved.
- **Fix:** rewrite README to match `release_plan.md`; move the cut features to
  `docs/backlog/shelved_features.md`.

---

## High — documentation references files that do not exist

### 4. `documentation_tracking.md` tracks phantom files
- `docs/documentation_tracking.md` marks as documented ([x]) files that are not
  present in the repo:
  - `src/scripts/singletons/leaderboard_manager.gd` — does not exist
  - `src/scripts/singletons/environment_variables.gd` — does not exist
  - `src/scripts/singletons/scene_manger.gd` — does not exist (actual: `scene_loader.gd`)
  - `src/scripts/singletons/runtime_secrets.gd` — gitignored/absent
  - `src/scenes/training/main_multiplayer.gd` / `.tscn` — do not exist
  - `src/scenes/training/multiplayer_world.gd` / `.tscn` — do not exist
  - `src/ui/end_screen.gd` — does not exist (actual: `src/ui/menus/end_screen.gd`)
  - `src/ui/components/progress_bar.gd` — does not exist
- The architecture doc and backlog say multiplayer/leaderboard systems were
  removed for V1.0, but the tracking file still lists them as "documented".
- **Fix:** prune `documentation_tracking.md` to reflect the current file tree.

### 5. `docs/systems/other_scripts/other_scripts.md` documents removed scripts
- It documents `environment_variables.gd`, `scene_manager.gd` (with a note about
  a `SceneManger` typo), and `runtime_secrets.gd` — none of which exist in the
  tree (the scene manager is now `scene_loader.gd` / `SceneLoader`, and
  `environment_variables.gd` was folded into the hidden training scene per
  `architecture.md`).
- It also lists `constants.gd` properties that no longer exist: `MEDAL_COLORS`,
  `POWERUPS`, `LEVELS`, `MULTIPLAYER_LEVELS`, `MEDAL_NAMES`, and
  `get_next_level()`. The actual `constants.gd` (13 lines) only has
  `DEFAULT_PLAYER_NAME` and four preloaded resource consts.
- **Fix:** rewrite or remove this doc to match the current `constants.gd`,
  `utils.gd`, and `scene_loader.gd`.

### 6. `docs/systems/leaderboard_system/leaderboard_system.md` documents removed system
- Describes a `leaderboard_manager.gd` singleton (SilentWolf integration) that is
  not in the repo and is explicitly deferred per `architecture.md`
  ("Online leaderboards — deferred to post-launch").
- The UI `leaderboard.gd` / `leaderboard_entry.gd` do exist, but the doc ties
  them to the nonexistent manager and SilentWolf signals.
- **Fix:** mark this doc as "deferred/post-launch" or move to
  `docs/backlog/research_ideas.md`; document only the local UI components that
  actually exist.

---

## Medium — autoload roster mismatch

### 7. `project.godot` autoloads diverge from `architecture.md`
- `architecture.md` approves **5 core** autoloads (SaveManager, SceneLoader,
  AudioManager, Settings, GameSession) plus 2 helpers (Constants, SignalBus) as
  transitional — 7 total.
- `project.godot` registers **10**: the 7 above plus `RuntimeSecrets`,
  `ArcadeDirector`, `TelemetrySystem`, `MonetizationSystem`.
- `ArcadeDirector` is used by `main.gd` (arcade mode), and `TelemetrySystem` is
  used by `main.gd` — so they are real. But they are not listed in the
  architecture doc, and `MonetizationSystem` is not referenced anywhere in the
  code I searched.
- **Fix:** update `architecture.md` to include `ArcadeDirector` and
  `TelemetrySystem`; verify `MonetizationSystem` is actually used, else remove
  the autoload and its file.

---

## Medium — duplicate/legacy docs structure

### 8. Two parallel docs trees
- The repo has both:
  - `docs/main_system/`, `docs/player_system/`, `docs/save_system/`, etc.
    (legacy flat structure), and
  - `docs/systems/main_system/`, `docs/systems/player_system/`, etc.
    (the new "vault" structure referenced by `00_index.md`).
- `00_index.md` only links into `docs/systems/`. The legacy `docs/*_system/`
  folders are orphaned and will silently drift out of date.
- **Fix:** delete the legacy `docs/main_system/`, `docs/player_system/`, …
  directories (or redirect them) and keep only `docs/systems/`.

### 9. `docs/save_system/campaing_level_data.md` still uses the misspelled name
- Backlog item #16 says `CampaingLevelData` → `CampaignLevelData` rename is
  pending. The code search shows the class is already `CampaignLevelData`
  (`src/scripts/resources/campaign_level_data.gd` exists, and
  `CampaingLevelData` returns zero hits), but the **doc file** is still named
  `campaing_level_data.md` and `documentation_tracking.md` still says "rename
  pending".
- **Fix:** rename the doc file to `campaign_level_data.md` and update links in
  `documentation_tracking.md` and `00_index.md`-adjacent docs.

---

## Low — misc README/doc polish

### 10. README is missing setup/build instructions
- No "How to open", "How to run", "How to export", or "How to run tests"
  instructions. `run_tests.sh` / `run_tests.bat` exist but are undocumented.
- **Fix:** add a short "Getting started" section pointing at `project.godot`
  and `run_tests.sh`.

### 11. README line 54 is a bare command fragment
- Line 54: `graphify . --backend ollama --model qwen3.5:35b-mlx` appears to be a
  stray shell snippet with no heading or context, and references a model
  (`qwen3.5:35b-mlx`) that is not mentioned elsewhere.
- **Fix:** remove or wrap in a proper example block (after adding the tool per
  item #2).

### 12. (Resolved on inspection) `docs/00_index.md` sprint link is valid
- `[[project/sprints/sprint-2026-07-25]]` resolves —
  `docs/project/sprints/sprint-2026-07-25.md` exists. No action needed.

---

## Summary of recommended first actions

1. **Unblock fresh clones:** add a `runtime_secrets.gd` template or make the
   autoload optional (item #1).
2. **Fix README:** remove the nonexistent Graphify tool section and align scope
   with `release_plan.md` (items #2, #3, #10, #11).
3. **Prune phantom docs:** delete `documentation_tracking.md` entries and
   system docs for removed files (items #4, #5, #6).
4. **Reconcile architecture doc** with the actual autoload list (item #7).
5. **Delete legacy `docs/*_system/` trees** in favor of `docs/systems/` (item #8).