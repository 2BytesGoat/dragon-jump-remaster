---
title: UI Components Documentation
tags: [godot, game-engine, ui, user-interface, components]
related:
  - "[[technical/player-system]]"
  - "[[technical/leaderboard]]"
  - "[[technical/save-system/index]]"
search_terms: [ui-components, menu-system, player-ui, leaderboard-ui, progress-bar, time-display, game-menus]
---

# UI Components Documentation

## Overview
The UI Components system provides all the user interface elements used throughout the Dragon Jump Remaster game. This includes main menus, level selection screens, end screens, progress indicators, and various other visual components that enhance player interaction with the game.

Key search terms and concepts for RAG retrieval: ui-components, menu-system, player-ui, leaderboard-ui, progress-bar, time-display, game-menus
System relationships and dependencies: This system integrates with player system for player data, save system for player names and stats, leaderboard system for score display, and main system for overall game flow.

## Script Components (`*.gd`)

### `main_menu.gd`
- **Purpose**: Main menu screen that provides access to different game modes and settings. Shows a title screen with a blinking "Press JUMP to Start" prompt and a `PlayerMock` that jumps off-screen on jump input before revealing the selection buttons.
- **Key properties**:
  - `start_container` / `selection_container`: The two stacked menu states (title prompt vs. button column), toggled by the start sequence
  - `player_mock`: `TextureRect` showing the player sprite via an `AtlasTexture` (duplicated at runtime so frames can be swapped by region)
  - `press_key_label`: The blinking "Press JUMP to Start" label
  - `jump_sfx`: `AudioStreamPlayer` on the SFX bus playing `swoosh.ogg` (same sound as the in-game jump effect)
- **Layout** (compact arcade style): primary column of PLAY / PRACTICE / CREATE, then a footer row of small buttons: SETTINGS / CREDITS / DISCORD / WEB / QUIT
- **Main methods**:
  - `_ready()`: Shows the start container, hides the selection container, duplicates the mock's atlas texture, and starts the label blink tween. If `GameSession.menu_started` is already true (the player pressed JUMP earlier this session), it skips the title sequence and shows the selection container directly
  - `_unhandled_input()`: On `player_one_jump` (space / joypad A), sets `GameSession.menu_started = true` and starts the jump sequence
  - `_set_player_frame(coords)`: Swaps the mock's atlas region to the given sprite-sheet coordinates (`IDLE_COORDS` / `JUMP_COORDS` / `FALL_COORDS`)
  - `_start_jump_sequence()`: Kills the blink, plays the jump SFX, switches the mock to the jump frame, and tweens it along the real jump arc (jump gravity to peak, then fall gravity) while drifting horizontally at the player's move speed, until it leaves the screen, fading it out near the bottom
  - `_jump_arc_step(t)`: Integrates the arc analytically; switches the mock to the fall frame once past the peak and moves it horizontally at `PhysicsParams.max_speed`
  - `_on_jump_sequence_finished()`: Hides the start container and fades the selection container in (`FADE_IN_DURATION`), then focuses the Play button (only runs once the mock's bottom edge is `EXIT_MARGIN` px past the bottom of the screen)
  - `_on_play_button_pressed()`: Starts an arcade run via `ArcadeDirector.start_arcade_run()` and navigates to `res://main.tscn` via `SceneLoader`
  - `_on_credits_button_pressed()`: Emits `credits_requested` so the host (`main_screen.gd`) can show the credits overlay
  - `_on_practice_button_pressed()`: Emits `practice_requested` so the host (`main_screen.gd`) can show the practice menu
  - `focus_credits_button()`: Restores keyboard focus to the credits button after the overlay closes
  - `focus_practice_button()`: Restores keyboard focus to the practice button after the practice menu closes
- **Integration points with other systems**:
  - Jump arc constants come from `Constants.PHYSICS_PARAMS` (the same resource `Player` reads in `player.gd`), not re-declared locally
  - Connects to the `SceneLoader` autoload for scene navigation
  - Uses SaveManager to check player name
  - Uses Constants for default player name and social URLs
  - Uses Utils for player name validation
- **RAG metadata**: Performance considerations include efficient scene transitions, optimization hints involve preloading scenes and validating input early

### `practice_menu.gd` / `practice_menu.tscn`
- **Purpose**: Level picker for practice runs. Replaces the old `level_select` flow: browse campaign levels, preview the selected level in a `SubViewport`, tune player speed, and start a run by pressing JUMP (no confirmation screen). Lives inside `main_screen.tscn` as a full-rect sibling of `MainMenu`; the standalone `practice_menu.tscn` is the same subtree with the script attached.
- **Note**: The preview `ViewportTexture` uses a root-relative `viewport_path` (`NodePath("SubViewport")`), resolved from `PracticeMenu` itself — do not prefix with `PracticeMenu/` (that path is only valid when the subtree was embedded in `main_screen.tscn`, and breaks the standalone scene).
- **Key properties**:
  - `level_button_container`: `VBoxContainer` rebuilt at runtime from `CampaignLevelLibrary` (hidden levels skipped, unplayed levels disabled, labels formatted `level_id - Name`, e.g. `1-1 - Your Turn`)
  - `level_node`: the `Level` instance inside the preview `SubViewport`, loaded on selection/hover
  - `speed_slider`: player speed multiplier (0.75–1.0, mapped `0.75 + value * 0.25`)
  - `selected_level_name`: the currently selected campaign level id
- **Main methods**:
  - `_ready()`: Emits `TelemetrySystem.menu_opened("practice")`, rebuilds the level button list, selects and focuses the first level (without starting a run)
  - `_unhandled_input()`: While visible, `player_one_jump` starts the run (`GameSession.start_run` + `SceneLoader.go_to("res://main.tscn")`) and `ui_cancel` emits `closed`
  - `_on_level_button_clicked(level_name)`: Sets `selected_level_name`, updates the display, and starts the run — mouse clicks and keyboard accept both launch the run directly
  - `_on_level_button_hovered(level_name)`: Sets `selected_level_name` and updates the preview and stats on hover or focus (via `_update_level_display`). Mouse hover grabs focus, so mouse and controller/keyboard navigation share the same focus-driven path; the focused level is always the run target
  - `_update_level_display(level_name)`: Loads the level preview and updates best time / attempts / progress bar / medal / selected label from `SaveManager`
  - `focus_first_level()`: Resets the level list scroll to the top and focuses the first level button, re-resetting the scroll after the layout pass (`await process_frame`) so `follow_focus` doesn't keep a stale offset computed while the menu was hidden (called by the host when the menu is shown)
- **Signals**: `closed` — emitted on `ui_cancel` so the host can return to the main menu
- **Integration points**: `CampaignLevelLibrary` (level list), `SaveManager` (per-level stats), `GameSession` (run start), `SceneLoader` (navigation), `TelemetrySystem` (menu telemetry)

### `custom_levels_menu.gd` / `custom_levels_menu.tscn`
- **Purpose**: Browse imported custom levels, import new ones by pasting a level code (name + code via `LevelCodeParser` validation), play them, or delete them. Levels persist via `CustomLevelStore` (`user://custom_levels.json`).
- **Main methods**:
  - `_ready()`: Refreshes the level list and focuses import
  - `_on_play_button_pressed()`: Calls `GameSession.start_custom_run(code)` and navigates to the game scene
  - `_on_import_confirm_pressed()`: Validates and stores an imported level
  - `_on_delete_button_pressed()`: Removes the selected level
  - `_on_back_button_pressed()`: Returns to the main menu
- **Integration points**: `CustomLevelStore` (persistence), `LevelCodeParser` (validation), `GameSession` (custom run), `SceneLoader`

### `credits_screen.gd` / `credits_screen.tscn`
- **Purpose**: Full-screen overlay with a Star Wars-style rolling text crawl. Closes on any key / joypad button / mouse click, or automatically once the crawl has fully scrolled past the top of the screen (after a short `END_HOLD_DURATION` hold).
- **Main methods**:
  - `reset_crawl()`: Restarts the crawl from below the screen
  - `close()`: Fades the overlay out (`FADE_DURATION`), hides it, then emits `closed`
- **Signals**: `closed` — emitted after the fade-out completes, so the host can restore focus to the menu
- **Integration points**: Embedded in `main_screen.tscn` as a full-rect sibling of `MainMenu`; shown/hidden by `main_screen.gd` (fade-in on `credits_requested`, focus restored on `closed`). Its `_unhandled_input` ignores input while hidden so it never swallows the title-screen jump key.

### `main_screen.gd` / `main_screen.tscn`
- **Purpose**: Root of the main menu. Hosts `MainMenu`, `PracticeMenu`, and the `CreditsScreen` overlay, toggling between them.
- **Main methods**:
  - `_ready()`: Connects `main_menu.credits_requested` / `main_menu.practice_requested` and `credits_screen.closed` / `practice_menu.closed`
  - `_on_practice_requested()`: Hides the main menu, shows the practice menu, and focuses its first level
  - `_on_practice_closed()`: Hides the practice menu, shows the main menu, and restores focus to the practice button
  - `_on_credits_requested()` / `_on_credits_closed()`: Fade the credits overlay in/out (see `credits_screen.gd`)
- **Integration points**: `main_menu.gd` (signals), `practice_menu.gd` (signals), `credits_screen.gd` (signals)

### `custom_level_store.gd`
- **Purpose**: Static helper (not an autoload) that persists player-imported custom levels to `user://custom_levels.json` as `{ id: { "name", "code" } }`.
- **Main methods**: `get_all()`, `get_level(id)`, `has_level(id)`, `add_level(id, name, code)`, `remove_level(id)`

### `end_screen.gd`
- **Purpose**: Displays game statistics when a run is completed
- **Key properties**:
  - None specific to the component
- **Main methods**:
  - `show_stats(stats: Dictionary)`: Displays player statistics in UI labels, with the level title formatted `level_id - Name` (e.g. `1-1 - Your Turn`) from `CampaignLevelLibrary.display_name.capitalize()`
- **Integration points with other systems**:
  - Updates UI labels with data from game stats
  - Connected to game completion events
- **RAG metadata**: Visual design patterns include simple panel layout with labeled statistics

### `run_timer.gd` / `time_display.gd` / `arcade_rank_hud.tscn`
- **Purpose**: The run clock (`RunTimer`, `src/scripts/components/run_timer.gd`) lives at the main scene root and is the single source of truth for run time. `TimeDisplay` (`src/ui/components/time_display.gd`) is the display-only timer label inside the HUD (`TimeContainer`), fed by `RunTimer.time_changed`.
- Documented in [[technical/ui/arcade-hud]]. See that doc for the player-signal flow and flush points; `src/ui/components/time_container.tscn` is a stale, unused draft.

### `bonus_popup.gd` / `bonus_popup.tscn` / `bonus_popup_config.tres`
- **Purpose**: Reusable one-shot "+bonus" popup that animates above a world position and frees itself. Spawned by `ArcadeRankHud` at level clear and by `BonusPopup.spawn()` from anywhere; timing tuned via `resources/bonus_popup_config.tres`.

### `default_theme.tres` / `gameplay_theme.tres` / `practice_theme.tres`
- **Purpose**: The three UI themes. `default_theme.tres` is the global theme (`project.godot` → `gui/theme/custom`) for all menus; `gameplay_theme.tres` (`PressStart2P`) is applied to the live HUD, bonus popups, and powerup cards (see [[technical/ui/arcade-hud]]).
- **`practice_theme.tres`** is a derived theme for the practice menu ([[technical/ui/index]] — see `practice_menu.tscn`). It sets `base_theme` to `default_theme.tres` so it inherits everything, then overrides:
  - **Body text** (`Label` default) → `PressStart2P-Regular.ttf` at size 10, so list items, stat values, and level buttons render in the "other" font
  - **Headers** (`Label` type variation `"HeaderLabel"`) → `Awesome 9.ttf` at size 18, applied via `theme_type_variation = &"HeaderLabel"` on section/stat labels (Player Speed:, Select Level:, MASTERY:, the level title, Attempts:, Your Best:, World Best:)
  - **`HSlider` skins** → silver track (`silver_slider_empty.png` as the `slider` stylebox) and silver grabber (`silver_grabber_normal.png` / `silver_grabber_pressed.png` as `grabber_icon` / `grabber_icon_pressed`), plus a white-outline focus box matching the Button focus style. These only affect sliders under the practice menu — settings-menu sliders keep the unstyled global theme.
- **Button highlight is focus-driven, not hover-driven**: both base themes set `Button/styles/hover` to an empty `StyleBoxEmpty` (killing Godot's default gray hover shading) and `Button/styles/focus` to a `StyleBoxFlat` highlight (semi-transparent white fill + 1px white border). The focused button is the highlighted one — mouse hover still grabs focus (see `level_button.gd`), so mouse and keyboard/controller navigation share the same focus highlight. `practice_theme.tres` inherits this via `base_theme`, but overrides `Button/styles/focus` with a **brown** highlight (same brown as the book theme's `Label` text, 15%-alpha fill + 1px border) to match the light parchment pages; `Button/styles/hover` stays empty (inherited).
- Documented in [[technical/ui/arcade-hud]].

### `progress_bar.gd` *(removed)*
Progress-bar mode was cut for V1.0 (see [[technical/architecture]]). No such file exists in the repo.

## Scene Components (`*.tscn`)
### `main_menu.tscn`
- **Scene hierarchy and organization**: MarginContainer containing logo, a start container (PlayerMock + blinking "Press JUMP to Start" label), the primary button column (PLAY / PRACTICE / CREATE), footer row (SETTINGS / CREDITS / DISCORD / WEB / QUIT), and a `JumpSFX` `AudioStreamPlayer` on the SFX bus
- **Key connections between elements**:
  - `PlayerMock` is a `TextureRect` on an `AtlasTexture` of `player_v3.png`; the script swaps the atlas region between idle / jump / fall coordinates on jump input
  - `StartContainer`, `SelectionContainer`, `PlayerMock`, `PressKeyLabel`, and `PlayButton` are unique-name nodes referenced by `main_menu.gd`
  - Connects to button press signals for navigation
  - Uses the `SceneLoader` autoload for scene transitions
- **Visual layout considerations**: 
  - Uses MarginContainer for proper positioning
  - Includes responsive UI elements
- **RAG metadata**: Visual design patterns include layered containers, responsive layouts

### `end_screen.tscn`
- **Scene hierarchy and organization**: Simple Panel with labeled statistics (time, resets, crowns dropped)
- **Key connections between elements**:
  - Displays data passed from game logic
  - No complex connections beyond showing/hiding
- **Visual layout considerations**:
  - Clean panel layout for displaying stats
  - Labels positioned for clear readability
- **RAG metadata**: Visual design patterns include simple statistic display with clear labeling

### `progress_bar.tscn` *(removed)*
No such file exists in the repo.

### `arcade_rank_hud.tscn` / `time_container.tscn`
- **Purpose**: `arcade_rank_hud.tscn` (in `src/ui/hud/`) is the live gameplay HUD (lives, timer label, rank bar, score). Its nested `TimeContainer` runs `time_display.gd` (display-only); the clock itself is `RunTimer` at the main root — see the Script Components section above.
- `time_container.tscn` is a **stale, unused** draft scene; the live timer is inside `arcade_rank_hud.tscn`.

## System Integration
- How the system interacts with other components: UI components connect to various game systems through signals and data passing, providing visual feedback for player actions and game events
- Signal-based communication patterns: UI components consume player lifecycle signals (`run_started`, `run_restarted`, `run_finished`) directly and use SignalBus for cross-scene events (e.g. `play_time_elapsed` for the retention timer)
- Data flow and control flow: Game data → Player system → UI components → Displayed to user
- Cross-system relationships for RAG linking: Related to player system (player events), save system (player data), leaderboard system (score display), main system (game flow)

## Design Patterns
- Architecture patterns used: Component pattern for UI elements, Observer pattern for event handling
- Code organization principles: Separation of concerns between UI presentation and game logic
- Reusability considerations: Shared menu and HUD components can be reused across contexts
- Pattern-specific RAG tags and categorization: component-pattern, observer-pattern, ui-system

## Implementation Details
- Key code examples:
  - `SceneLoader.go_to(level_select)` - Navigation between scenes
  - `show_stats(stats)` - Displaying game statistics
- Important algorithms or logic: 
  - Scene navigation with command-line argument checking
- Performance considerations: Efficient scene transitions, preloaded scenes

## See Also
- [[technical/player-system]]
- [[technical/leaderboard]]
- [[technical/save-system/index]]