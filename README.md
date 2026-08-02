# Dragon Jump Remaster

A single-button arcade speedrun platformer built in Godot 4.

## What is this?

Dragon Jump Remaster is a **single-player arcade speedrun platformer** for Windows, Linux, macOS, and Web. The V1.0 release focuses on a tight one-button loop: jump, reset, chase medals, and beat the clock across 10–20 handcrafted levels.

See [`docs/direction/product_identity.md`](docs/direction/product_identity.md) for the full product pitch and [`docs/direction/release_plan.md`](docs/direction/release_plan.md) for the locked V1.0 scope.

## Getting started

### Open the project

1. Install [Godot 4.x](https://godotengine.org/download) (version pinned during Phase 1).
2. Open `project.godot` in the Godot editor.
3. Press **F5** (or the play button) to run the game from the main scene.

No build step is required for local development.

### Runtime secrets (release builds only)

`SaveManager` signs save files with an HMAC secret that is injected at build time. The committed project does **not** include the real secret, so a fresh clone loads without it.

For release builds, copy the template and fill in the real value:

```bash
cp src/scripts/singletons/runtime_secrets.gd.template src/scripts/singletons/runtime_secrets.gd
```

Then edit `src/scripts/singletons/runtime_secrets.gd`:

```gdscript
var is_set := true
var HMAC_SECRET := "YOUR_BUILD_PIPELINE_SECRET"
```

The `.gd` file is gitignored and must never be committed. The build pipeline can also register `RuntimeSecrets` as an autoload in `project.godot` when injecting the real secret.

### Run tests

```bash
./run_tests.sh
```

A Windows batch file is also available: `run_tests.bat`.

## V1.0 scope

Dragon Jump Remaster V1.0 ships as a single-player arcade speedrun platformer:

- One-button jump/reset loop
- 10–20 handcrafted campaign levels
- Local high-score and best-time tracking
- Medal progression and local save encryption
- Title → level select / endless mode → run → death/retry → score screen
- Windows, Linux, macOS, and Web exports

Features intentionally **out of V1.0** (post-launch or shelved):

- Online leaderboards and networked multiplayer
- Level editor and player-made maps
- Co-op / bot race and crown/tag modes
- Phone-as-controller local multiplayer

See [`docs/backlog/shelved_features.md`](docs/backlog/shelved_features.md) for the full list.

## Documentation

This repo uses an Obsidian-style docs vault under `docs/`:

- [`docs/00_index.md`](docs/00_index.md) — vault entry point
- [`docs/direction/`](docs/direction/) — game design and release plan
- [`docs/systems/`](docs/systems/) — technical reference for code and scenes
- [`docs/tracking/`](docs/tracking/) — backlog, sprints, and decision log
- [`docs/backlog/`](docs/backlog/) — shelved features and research ideas

## License

See [`LICENSE`](LICENSE).
